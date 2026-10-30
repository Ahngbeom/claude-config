#!/usr/bin/env python3
import importlib.util
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

HOOK = Path(__file__).resolve().parent.parent / "guard-work-checkout.py"
sys.path.insert(0, str(HOOK.parent))
spec = importlib.util.spec_from_file_location("guard", HOOK)
guard = importlib.util.module_from_spec(spec)
spec.loader.exec_module(guard)


class GuardWorkCheckoutTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.work = Path(self.tmp.name) / "work"
        (self.work / "repo" / ".git").mkdir(parents=True)
        (self.work / "linked").mkdir()
        (self.work / "linked" / ".git").write_text("gitdir: /elsewhere\n")
        (self.work / "plain").mkdir()
        (self.work / ".worktrees" / "repo-feat-x").mkdir(parents=True)
        (self.work / ".worktrees" / "repo-feat-x" / ".git").write_text("gitdir: x\n")
        guard.WORK = self.work
        self.repo = str(self.work / "repo")
        self.tree = str(self.work / ".worktrees" / "repo-feat-x")

    def tearDown(self):
        self.tmp.cleanup()

    def edit(self, path, cwd=None):
        return guard.find_block_reason("Edit", {"file_path": path}, cwd or self.repo)

    def bash(self, command, cwd=None):
        return guard.find_block_reason("Bash", {"command": command}, cwd or self.repo)

    def test_edit_in_main_checkout_is_blocked(self):
        self.assertIsNotNone(self.edit(f"{self.repo}/src/a.py"))
        self.assertIsNotNone(guard.find_block_reason("Write", {"file_path": f"{self.repo}/new.md"}, self.repo))
        self.assertIsNotNone(guard.find_block_reason("NotebookEdit", {"notebook_path": f"{self.repo}/n.ipynb"}, self.repo))

    def test_relative_edit_path_resolves_against_cwd(self):
        self.assertIsNotNone(self.edit("src/a.py", cwd=self.repo))

    def test_edit_outside_main_checkouts_is_allowed(self):
        self.assertIsNone(self.edit(f"{self.tree}/src/a.py"))
        self.assertIsNone(self.edit(f"{self.work}/linked/a.py"))
        self.assertIsNone(self.edit(f"{self.work}/plain/a.md"))
        self.assertIsNone(self.edit(f"{self.work}/CLAUDE.md"))
        self.assertIsNone(self.edit("/tmp/x.txt"))

    def test_git_mutation_in_main_checkout_is_blocked(self):
        for cmd in [
            "git commit -m x",
            "git checkout -b feat/x",
            "git switch develop",
            "git pull",
            "git stash",
            "git reset --hard",
            "git restore a.py",
            "git add .",
            "git -c core.x=y merge origin/main",
            "GIT_EDITOR=true git rebase origin/main",
        ]:
            with self.subTest(cmd=cmd):
                self.assertIsNotNone(self.bash(cmd))

    def test_git_dash_c_and_cd_target_main_checkout(self):
        self.assertIsNotNone(self.bash(f"git -C {self.repo} commit -m x", cwd=self.tree))
        self.assertIsNotNone(self.bash(f"cd {self.repo} && git checkout main", cwd=self.tree))
        self.assertIsNotNone(self.bash(f"git status; git -C {self.repo}/sub add a", cwd=self.tree))

    def test_symlink_into_main_checkout_is_blocked(self):
        link = Path(self.tmp.name) / "repo-link"
        link.symlink_to(self.repo)
        self.assertIsNotNone(self.edit(f"{link}/a.py", cwd=self.tree))
        self.assertIsNotNone(self.bash(f"cd {link} && git commit -m x", cwd=self.tree))
        self.assertIsNotNone(self.bash(f"git -C {link} add a", cwd=self.tree))

    def test_git_dir_and_work_tree_target_main_checkout(self):
        git_dir = f"{self.repo}/.git"
        outside = Path(self.tmp.name) / "outside"
        for cmd in [
            f"git --git-dir={git_dir} --work-tree={self.repo} add a",
            f"git --git-dir {git_dir} commit -m x",
            f"git --git-dir={git_dir} --work-tree={outside} add a",
            f"git --work-tree {self.repo} add a",
            f"cd {self.work} && git --git-dir=repo/.git commit -m x",
            f"GIT_DIR={git_dir} git commit -m x",
            f"GIT_WORK_TREE={self.repo} git add a",
        ]:
            with self.subTest(cmd=cmd):
                self.assertIsNotNone(self.bash(cmd, cwd=self.tree))
        self.assertIsNone(self.bash(f"git --git-dir={outside}/.git --work-tree={outside} commit -m x", cwd=self.tree))
        self.assertIsNone(self.bash(f"GIT_DIR={outside}/.git git commit -m x", cwd=self.tree))

    def test_read_only_and_worktree_git_is_allowed_in_main_checkout(self):
        for cmd in [
            "git status --short",
            "git log --oneline -10",
            "git diff --stat",
            "git fetch origin",
            "git branch -a",
            "git stash list",
            "git stash show -p",
            f"git worktree add --no-track -b feat/x {self.tree} origin/develop",
            f"git worktree remove {self.tree}",
            "git branch -d feat/x",
        ]:
            with self.subTest(cmd=cmd):
                self.assertIsNone(self.bash(cmd))

    def test_git_mutation_in_worktree_is_allowed(self):
        self.assertIsNone(self.bash("git commit -m x", cwd=self.tree))
        self.assertIsNone(self.bash(f"cd {self.tree} && git rebase origin/main", cwd=self.repo))
        self.assertIsNone(self.bash(f"git -C {self.tree} add .", cwd=self.repo))

    def test_pin_escape_env_is_blocked_in_any_session(self):
        for cmd in [
            "CANONICAL_PIN_ALLOW=1 git reset --hard HEAD~1",
            "export CANONICAL_PIN_ALLOW=1; git -C x reset --hard y",
            "env GIT_TRACE=1 CANONICAL_PIN_ALLOW=1 git update-ref -d refs/heads/main",
        ]:
            for override in (False, True):
                with self.subTest(cmd=cmd, override=override):
                    self.assertIsNotNone(guard.find_block_reason("Bash", {"command": cmd}, "/tmp", override))

    def test_pin_escape_mentioned_in_text_is_allowed(self):
        for cmd in [
            "grep -rn CANONICAL_PIN_ALLOW ~/.claude/hooks",
            "echo 'run CANONICAL_PIN_ALLOW=1 git reset --hard X yourself'",
        ]:
            with self.subTest(cmd=cmd):
                self.assertIsNone(guard.find_block_reason("Bash", {"command": cmd}, "/tmp"))

    def test_unparseable_or_non_git_command_is_allowed(self):
        self.assertIsNone(self.bash("echo 'unterminated"))
        self.assertIsNone(self.bash("grep -r commit ."))
        self.assertIsNone(self.bash("echo git commit"))


def git(*args, cwd):
    subprocess.run(["git", *args], cwd=cwd, check=True, capture_output=True)


def commit(cwd, name):
    Path(cwd, name).write_text(name)
    git("add", name, cwd=cwd)
    git("-c", "user.name=t", "-c", "user.email=t@t", "commit", "-qm", name, cwd=cwd)


class RepoFixture(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        root = Path(self.tmp.name)
        self.work = root / "work"
        self.work.mkdir()
        guard.WORK = self.work

        origin = root / "origin.git"
        git("init", "-q", "--bare", "-b", "develop", str(origin), cwd=root)
        seed = root / "seed"
        git("clone", "-q", str(origin), str(seed), cwd=root)
        git("checkout", "-qb", "develop", cwd=seed)
        commit(seed, "a")
        git("push", "-q", "origin", "develop", cwd=seed)
        git("push", "-q", "origin", "develop:feat/r", cwd=seed)
        self.remote = self.work / "srv"
        git("clone", "-q", str(origin), str(self.remote), cwd=root)

        self.local = self.work / "ops"
        self.local.mkdir()
        git("init", "-q", "-b", "main", cwd=self.local)
        commit(self.local, "a")
        git("branch", "feat/x", cwd=self.local)

    def tearDown(self):
        self.tmp.cleanup()

    def bash(self, command, cwd, override=False):
        return guard.find_block_reason("Bash", {"command": command}, str(cwd), override)


class FastForwardUpdateTest(RepoFixture):
    """원본 checkout은 고정 브랜치에서 fast-forward로만 갱신하고, 고정 브랜치로만 전환한다."""

    def test_ff_merge_of_upstream_on_default_branch_is_allowed(self):
        self.assertIsNone(self.bash("git merge --ff-only origin/develop", self.remote))
        self.assertIsNone(self.bash(f"git fetch origin && git -C {self.remote} merge --ff-only origin/develop", self.work))

    def test_ff_merge_of_local_branch_is_allowed_only_without_remote(self):
        self.assertIsNone(self.bash("git merge --ff-only feat/x", self.local))
        git("branch", "feat/y", cwd=self.remote)
        self.assertIsNotNone(self.bash("git merge --ff-only feat/y", self.remote))

    def test_other_merge_forms_stay_blocked(self):
        for cmd in [
            "git merge origin/develop",
            "git merge --no-ff --ff-only origin/develop",
            "git merge --ff-only --squash origin/develop",
            "git -c merge.ff=false merge --ff-only origin/develop",
            "git merge --ff-only origin/develop origin/other",
            "git pull",
            "git pull origin develop",
            "git pull --rebase --ff-only",
            "git pull --ff-only origin feat/r",
            "git pull --ff-only upstream develop",
        ]:
            with self.subTest(cmd=cmd):
                self.assertIsNotNone(self.bash(cmd, self.remote))

    def test_dirty_tracked_file_blocks_ff_merge(self):
        Path(self.local, "a").write_text("changed")
        self.assertIsNotNone(self.bash("git merge --ff-only feat/x", self.local))

    def test_untracked_file_does_not_block_ff_merge(self):
        Path(self.local, "scratch.txt").write_text("x")
        self.assertIsNone(self.bash("git merge --ff-only feat/x", self.local))

    def test_non_default_branch_blocks_ff_merge(self):
        git("checkout", "-qb", "feat/z", cwd=self.remote)
        self.assertIsNotNone(self.bash("git merge --ff-only origin/feat/z", self.remote))
        git("checkout", "-q", "feat/x", cwd=self.local)
        self.assertIsNotNone(self.bash("git merge --ff-only main", self.local))


    def test_ff_pull_of_pinned_branch_is_allowed(self):
        for cmd in ["git pull --ff-only", "git pull -q --ff-only origin", "git pull --ff-only origin develop"]:
            with self.subTest(cmd=cmd):
                self.assertIsNone(self.bash(cmd, self.remote))
        self.assertIsNone(self.bash(f"git -C {self.remote} pull --ff-only", self.work))

    def test_ff_pull_needs_pinned_branch_and_clean_tree(self):
        git("checkout", "-q", "feat/r", cwd=self.remote)
        self.assertIsNotNone(self.bash("git pull --ff-only", self.remote))
        git("checkout", "-q", "develop", cwd=self.remote)
        Path(self.remote, "a").write_text("changed")
        self.assertIsNotNone(self.bash("git pull --ff-only", self.remote))

    def test_switch_back_to_pinned_branch_is_allowed(self):
        git("checkout", "-q", "feat/r", cwd=self.remote)
        self.assertIsNone(self.bash("git switch develop", self.remote))
        self.assertIsNone(self.bash("git checkout -q develop", self.remote))
        git("checkout", "-q", "feat/x", cwd=self.local)
        self.assertIsNone(self.bash("git switch main", self.local))

    def test_switch_away_from_pinned_branch_is_blocked(self):
        for cmd in [
            "git switch feat/r",
            "git checkout feat/r",
            "git checkout -b feat/new",
            "git switch -c feat/new develop",
            "git checkout --detach develop",
            "git checkout -f develop",
            "git checkout -",
        ]:
            with self.subTest(cmd=cmd):
                self.assertIsNotNone(self.bash(cmd, self.remote))
        self.assertIsNotNone(self.bash("git switch feat/x", self.local))

    def test_dirty_tracked_file_blocks_switch_back(self):
        git("checkout", "-q", "feat/x", cwd=self.local)
        Path(self.local, "a").write_text("changed")
        self.assertIsNotNone(self.bash("git switch main", self.local))


class OverrideSessionTest(RepoFixture):
    """CLAUDE_ALLOW_MAIN_CHECKOUT=1 세션은 원본을 고칠 수 있어도 고정 브랜치를 벗어나지 못한다."""

    def test_switch_away_from_pinned_branch_is_blocked(self):
        for cmd in [
            "git switch feat/r",
            "git checkout feat/r",
            "git checkout -b feat/new",
            "git switch -c feat/new develop",
            "git checkout --detach develop",
            "git checkout -",
            "git -c x=y checkout feat/r",
        ]:
            with self.subTest(cmd=cmd):
                self.assertIsNotNone(self.bash(cmd, self.remote, override=True))
        self.assertIsNotNone(self.bash("git switch feat/x", self.local, override=True))

    def test_edits_commits_and_file_restore_are_allowed(self):
        self.assertIsNone(guard.find_block_reason("Edit", {"file_path": f"{self.remote}/a"}, str(self.remote), True))
        for cmd in ["git commit -m x", "git pull", "git checkout -- a", "git checkout a", "git switch develop"]:
            with self.subTest(cmd=cmd):
                self.assertIsNone(self.bash(cmd, self.remote, override=True))


class HookProcessTest(unittest.TestCase):
    def run_hook(self, payload, env_extra=None):
        env = {k: v for k, v in os.environ.items() if k != "CLAUDE_ALLOW_MAIN_CHECKOUT"}
        env.update(env_extra or {})
        return subprocess.run(
            [sys.executable, str(HOOK)], input=json.dumps(payload),
            capture_output=True, text=True, env=env, timeout=10,
        )

    def test_deny_json_and_override(self):
        with tempfile.TemporaryDirectory() as home:
            main = Path(home) / "work" / "repo"
            (main / ".git").mkdir(parents=True)
            payload = {"tool_name": "Edit", "tool_input": {"file_path": f"{main}/x"}, "cwd": str(main)}
            out = json.loads(self.run_hook(payload, {"HOME": home}).stdout)
            self.assertEqual(out["hookSpecificOutput"]["permissionDecision"], "deny")
            self.assertEqual(self.run_hook(payload, {"HOME": home, "CLAUDE_ALLOW_MAIN_CHECKOUT": "1"}).stdout, "")

    def test_bad_input_fails_open(self):
        r = subprocess.run([sys.executable, str(HOOK)], input="not json", capture_output=True, text=True)
        self.assertEqual((r.returncode, r.stdout), (0, ""))


if __name__ == "__main__":
    unittest.main()
