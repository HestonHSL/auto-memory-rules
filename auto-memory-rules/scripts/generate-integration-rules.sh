#!/bin/bash
# 生成 memory-integration.md 到不同编辑器的配置目录
# 从统一的模板文件生成，添加对应的 frontmatter

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="$SCRIPT_DIR/../templates/memory-integration.md"

# 动态检测项目根目录
if echo "$SCRIPT_DIR" | grep -q "/\.kiro/skills/\|/\.frieren/skills/\|/\.agents/skills/\|/\.agent/skills/"; then
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
    SKILLS_PATH_KIRO=".kiro/skills"
    SKILLS_PATH_FRIEREN=".frieren/skills"
    SKILLS_PATH_ANTIGRAVITY=".agents/skills"
else
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    SKILLS_PATH_KIRO=".kiro/skills"
    SKILLS_PATH_FRIEREN=".frieren/skills"
    SKILLS_PATH_ANTIGRAVITY=".agents/skills"
fi

# 显示使用说明
show_usage() {
    cat << EOF
使用方法: $0 [target-platform|auto|all]

支持的平台:
  kiro      - 生成到 .kiro/steering/memory-integration.md
  frieren   - 生成到 .frieren/rules/memory-integration.md
  antigravity - 生成到 .agents/rules/memory-integration.md
  claude    - 生成到 .claude/rules/memory-integration.md
  cursor    - 生成到 .cursor/rules/memory-integration.md
  all       - 强制生成所有支持的平台

示例:
  $0           # 自动探测并更新当前项目中的所有平台
  $0 auto      # 自动探测并更新当前项目中的所有平台
  $0 all       # 强制生成所有版本
  $0 kiro      # 只生成 Kiro 版本
  $0 frieren   # 只生成 Frieren 版本
  $0 antigravity # 只生成 Antigravity 版本
  $0 claude    # 只生成 Claude 版本
  $0 cursor    # 只生成 Cursor 版本

EOF
}

# 自动探测当前项目中需要生成 integration 的平台
detect_present_platforms() {
    local detected=()

    add_if_missing() {
        local target="$1"
        for existing in "${detected[@]}"; do
            if [ "$existing" = "$target" ]; then
                return
            fi
        done
        detected+=("$target")
    }

    if [ -d "$PROJECT_ROOT/.kiro" ] || [ -d "$PROJECT_ROOT/.kiro/skills" ]; then
        add_if_missing "kiro"
    fi

    if [ -d "$PROJECT_ROOT/.agents" ] || [ -d "$PROJECT_ROOT/.agents/skills" ] || [ -d "$PROJECT_ROOT/.agent" ] || [ -d "$PROJECT_ROOT/.agent/skills" ] || [ -f "$PROJECT_ROOT/AGENTS.md" ]; then
        add_if_missing "antigravity"
    fi

    if [ -d "$PROJECT_ROOT/.frieren" ] || [ -d "$PROJECT_ROOT/.frieren/skills" ] || [ -d "$PROJECT_ROOT/.frieren/rules" ]; then
        add_if_missing "frieren"
    fi

    if [ -d "$PROJECT_ROOT/.claude" ] || [ -d "$PROJECT_ROOT/.claude/skills" ] || [ -d "$PROJECT_ROOT/.claude/rules" ]; then
        add_if_missing "claude"
    fi

    if [ -d "$PROJECT_ROOT/.cursor" ] || [ -d "$PROJECT_ROOT/.cursor/skills" ] || [ -d "$PROJECT_ROOT/.cursor/rules" ] || [ -d "$PROJECT_ROOT/.agents/skills" ]; then
        add_if_missing "cursor"
    fi

    echo "${detected[*]}"
}

# 检查模板文件
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "❌ 模板文件不存在: $TEMPLATE_FILE"
    exit 1
fi

# 生成 Kiro 版本
generate_kiro() {
    local output_dir="$PROJECT_ROOT/.kiro/steering"
    local output_file="$output_dir/memory-integration.md"
    
    mkdir -p "$output_dir"
    
    # 生成 frontmatter
    cat > "$output_file" << 'EOF'
---
inclusion: always
description: "核心长期记忆集成规则。捕获纠错和修改要求，积累错误模式，形成自检清单。"
---

EOF
    
    # 添加内容，替换占位符
    sed "s|{SKILLS_PATH}|$SKILLS_PATH_KIRO|g" "$TEMPLATE_FILE" >> "$output_file"
    
    echo "✅ Kiro: $output_file"
}

# 生成 Frieren 版本
generate_frieren() {
    local output_dir="$PROJECT_ROOT/.frieren/rules"
    local output_file="$output_dir/memory-integration.md"
    
    mkdir -p "$output_dir"
    
    # 生成 frontmatter
    cat > "$output_file" << 'EOF'
---
agentRequested: true
description: "核心长期记忆集成规则。捕获纠错和修改要求，积累错误模式，形成自检清单。"
---

EOF
    
    # 添加内容，替换占位符
    sed "s|{SKILLS_PATH}|$SKILLS_PATH_FRIEREN|g" "$TEMPLATE_FILE" >> "$output_file"
    
    echo "✅ Frieren: $output_file"
}

# 生成 Antigravity 版本
generate_antigravity() {
    local output_dir="$PROJECT_ROOT/.agents/rules"
    local output_file="$output_dir/memory-integration.md"

    mkdir -p "$output_dir"

    sed "s|{SKILLS_PATH}|$SKILLS_PATH_ANTIGRAVITY|g" "$TEMPLATE_FILE" > "$output_file"

    echo "✅ Antigravity: $output_file"
}

# 生成 Claude 版本
generate_claude() {
    local output_dir="$PROJECT_ROOT/.claude/rules"
    local output_file="$output_dir/memory-integration.md"

    mkdir -p "$output_dir"
    sed "s|{SKILLS_PATH}|.claude/skills|g" "$TEMPLATE_FILE" > "$output_file"
    echo "✅ Claude: $output_file"
}

# 生成 Cursor 版本
generate_cursor() {
    local output_dir="$PROJECT_ROOT/.cursor/rules"
    local output_file="$output_dir/memory-integration.md"

    mkdir -p "$output_dir"
    sed "s|{SKILLS_PATH}|.cursor/skills|g" "$TEMPLATE_FILE" > "$output_file"
    echo "✅ Cursor: $output_file"
}

# 主函数
main() {
    local mode="${1:-auto}"
    local target_platforms=""

    case "$mode" in
        "auto")
            target_platforms="$(detect_present_platforms)"
            if [ -z "$target_platforms" ]; then
                echo "⚠️  未探测到 integration 目标平台（.kiro/.agents/.claude/.cursor/.frieren）"
                echo "请显式传入目标平台，或先初始化对应平台目录。"
                echo ""
                show_usage
                exit 1
            fi
            ;;
        "all")
            target_platforms="kiro frieren antigravity claude cursor"
            ;;
        "kiro"|"frieren"|"antigravity"|"claude"|"cursor")
            target_platforms="$mode"
            ;;
        "-h"|"--help")
            show_usage
            exit 0
            ;;
        *)
            echo "❌ 未知的目标平台: $mode"
            echo ""
            show_usage
            exit 1
            ;;
    esac

    echo "🎯 目标平台: $target_platforms"
    echo ""
    for target in $target_platforms; do
        case "$target" in
            "kiro")
                echo "📝 生成 Kiro 版本..."
                generate_kiro
                ;;
            "frieren")
                echo "📝 生成 Frieren 版本..."
                generate_frieren
                ;;
            "antigravity")
                echo "📝 生成 Antigravity 版本..."
                generate_antigravity
                ;;
            "claude")
                echo "📝 生成 Claude 版本..."
                generate_claude
                ;;
            "cursor")
                echo "📝 生成 Cursor 版本..."
                generate_cursor
                ;;
        esac
    done
    
    echo ""
    echo "✨ 生成完成！"
}

# 执行主函数
main "$@"
