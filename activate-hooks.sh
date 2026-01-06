#!/bin/bash

# Hookify 규칙 활성화 스크립트

echo "🔧 Hookify 규칙을 활성화합니다..."

# hookify list로 현재 규칙 확인
echo ""
echo "📋 현재 등록된 Hookify 규칙:"
claude hookify list

echo ""
echo "💡 규칙 활성화/비활성화하려면:"
echo "   claude hookify configure"
echo ""
echo "✅ 설정이 완료되었습니다."
