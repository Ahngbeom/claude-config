#!/usr/bin/env python3
import os
import re
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

HOOKS = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(HOOKS))
import canonical_pin  # noqa: E402

GIT_VERSION = tuple(int(x) for x in re.findall(r"\d+", subprocess.run(
    ["git", "--version"], capture_output=True, text=True).stdout)[:2])
ENV = {**os.environ, "GIT_AUTHOR_NAME": "t", "GIT_AUTHOR_EMAIL": "t@t",
       "GIT_COMMITTER_NAME": "t", "GIT_COMMITTER_EMAIL": "t@t"}
ENV.pop(canonical_pin.ALLOW_ENV, None)


def git(*args, cwd, env=None):
    return subprocess.run(["git", *args], cwd=cwd, capture_output=True, text=True, env={**ENV, **(env or {})})


def ok(*args, cwd):
    r = git(*args, cwd=cwd)
    assert r.returncode == 0, (args, r.stderr)
    return r.stdout.strip()


class ReferenceTransactionHookTest(unittest.TestCase):
    """원본에 canonical_pin 훅을 설치하고 실제 git 명령의 거부·허용을 확인한다."""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        root = Path(self.tmp.name)
        ok("init", "-q", "--bare", "-b", "develop", "origin.git", cwd=root)
        seed = root / "seed"
        ok("clone", "-q", "origin.git", "seed", cwd=root)
        ok("commit", "-q", "--allow-empty", "-m", "a", cwd=seed)
        ok("push", "-q", "origin", "develop", "develop:feat/r", cwd=seed)
        ok("clone", "-q", "origin.git", "repo", cwd=root)
        self.repo = root / "repo"
        self.tree = root / "tree"
        hook = Path(ok("rev-parse", "--path-format=absolute", "--git-path", "hooks", cwd=self.repo)) / "reference-transaction"
        hook.symlink_to(HOOKS / "canonical_pin.py")
        ok("commit", "-q", "--allow-empty", "-m", "b", cwd=seed)
        ok("push", "-q", "origin", "develop", cwd=seed)

    def tearDown(self):
        self.tmp.cleanup()

    def assertRejected(self, *args, cwd=None):
        r = git(*args, cwd=cwd or self.repo)
        self.assertNotEqual(r.returncode, 0, args)
        self.assertIn("canonical-pin", r.stderr)

    def test_sync_and_commit_on_pinned_branch_are_allowed(self):
        ok("fetch", "-q", "origin", cwd=self.repo)
        ok("pull", "-q", "--ff-only", cwd=self.repo)
        ok("commit", "-q", "--allow-empty", "-m", "c", cwd=self.repo)
        ok("stash", "list", cwd=self.repo)

    def test_pack_refs_is_allowed(self):
        ok("pull", "-q", "--ff-only", cwd=self.repo)
        before = ok("rev-parse", "HEAD", cwd=self.repo)
        loose = Path(ok("rev-parse", "--path-format=absolute", "--git-common-dir", cwd=self.repo)) / "refs/heads/develop"
        ok("pack-refs", "--all", cwd=self.repo)
        self.assertFalse(loose.exists())
        ok("commit", "-q", "--allow-empty", "-m", "c", cwd=self.repo)
        ok("gc", "-q", cwd=self.repo)
        self.assertFalse(loose.exists())
        self.assertEqual(ok("rev-parse", "HEAD~1", cwd=self.repo), before)

    def test_delete_of_packed_pinned_branch_is_rejected(self):
        ok("pack-refs", "--all", cwd=self.repo)
        self.assertRejected("update-ref", "-d", "refs/heads/develop")
        ok("commit", "-q", "--allow-empty", "-m", "c", cwd=self.repo)
        self.assertRejected("update-ref", "-d", "refs/heads/develop")

    def test_detach_is_rejected(self):
        self.assertRejected("checkout", "-q", "--detach")
        self.assertRejected("checkout", "-q", "origin/feat/r")
        self.assertEqual(ok("symbolic-ref", "--short", "HEAD", cwd=self.repo), "develop")

    def test_non_ff_move_and_delete_of_pinned_branch_are_rejected(self):
        ok("pull", "-q", "--ff-only", cwd=self.repo)
        before = ok("rev-parse", "HEAD", cwd=self.repo)
        self.assertRejected("reset", "-q", "--hard", "HEAD~1")
        self.assertRejected("update-ref", "-d", "refs/heads/develop")
        self.assertEqual(ok("rev-parse", "HEAD", cwd=self.repo), before)

    def test_allow_env_lets_human_roll_back(self):
        ok("pull", "-q", "--ff-only", cwd=self.repo)
        r = git("reset", "-q", "--hard", "HEAD~1", cwd=self.repo, env={canonical_pin.ALLOW_ENV: "1"})
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_worktree_work_is_allowed(self):
        ok("worktree", "add", "-q", "--no-track", "-b", "feat/x", str(self.tree), "origin/develop", cwd=self.repo)
        ok("commit", "-q", "--allow-empty", "-m", "w", cwd=self.tree)
        ok("switch", "-q", "-c", "feat/y", cwd=self.tree)
        ok("checkout", "-q", "--detach", cwd=self.tree)
        ok("worktree", "add", "-q", "--detach", str(self.tree) + "-detached", "origin/develop", cwd=self.repo)
        ok("worktree", "add", "-q", str(self.tree) + "-existing", "feat/r", cwd=self.repo)
        ok("worktree", "remove", str(self.tree), cwd=self.repo)
        ok("branch", "-q", "-D", "feat/x", cwd=self.repo)
        self.assertEqual(ok("symbolic-ref", "--short", "HEAD", cwd=self.repo), "develop")

    def test_pinned_branch_move_from_worktree_is_rejected(self):
        ok("fetch", "-q", "origin", cwd=self.repo)
        ok("worktree", "add", "-q", "--no-track", "-b", "feat/x", str(self.tree), "origin/develop", cwd=self.repo)
        ok("update-ref", "refs/heads/develop", "origin/develop", cwd=self.tree)
        self.assertRejected("update-ref", "refs/heads/develop", "develop~1", cwd=self.tree)

    @unittest.skipUnless(GIT_VERSION >= (2, 46), "git 2.46 미만은 심볼릭 ref 갱신을 훅에 넘기지 않음")
    def test_branch_switch_is_rejected(self):
        self.assertRejected("switch", "-q", "feat/r")
        self.assertRejected("checkout", "-q", "-b", "feat/new")
        self.assertRejected("symbolic-ref", "HEAD", "refs/heads/feat/r")
        ok("switch", "-q", "develop", cwd=self.repo)


class ViolationsTest(unittest.TestCase):
    """git 2.46+ 심볼릭 ref 입력 형식을 현재 git 버전과 무관하게 확인한다."""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.repo = self.tmp.name
        ok("init", "-q", "-b", "main", cwd=self.repo)
        ok("commit", "-q", "--allow-empty", "-m", "a", cwd=self.repo)

    def tearDown(self):
        self.tmp.cleanup()

    def test_symref_switch_away_is_a_violation_only_in_main_worktree(self):
        update = [("ref:refs/heads/main", "ref:refs/heads/feat", "HEAD")]
        self.assertEqual(len(canonical_pin.violations(update, self.repo, True)), 1)
        self.assertEqual(canonical_pin.violations(update, self.repo, False), [])

    def test_symref_switch_to_pinned_is_allowed(self):
        update = [("ref:refs/heads/feat", "ref:refs/heads/main", "HEAD")]
        self.assertEqual(canonical_pin.violations(update, self.repo, True), [])

    def test_unrelated_refs_skip_pinned_lookup(self):
        update = [("0" * 40, "1" * 40, "refs/remotes/origin/x"), ("0" * 40, "1" * 40, "refs/tags/v1")]
        self.assertEqual(canonical_pin.violations(update, "/nonexistent", True), [])


if __name__ == "__main__":
    unittest.main()
