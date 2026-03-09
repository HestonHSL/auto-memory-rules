#!/bin/bash
# 生成 memory-integration.md 到不同编辑器的配置目录
# 从统一的模板文件生成，添加对应的 frontmatter

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="$SCRIPT_DIR/../templates/memory-integration.md"

# 动态检测项目根目录
if echo "$SCRIPT_DIR" | grep -q "/\.kiro/skills/\|/\.frieren/skills/"; then
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
    SKILLS_PATH_KIRO=".kiro/skills"
    SKILLS_PATH_FRIEREN=".frieren/skills"
else
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    SKILLS_PATH_KIRO=".kiro/skills"
    SKILLS_PATH_FRIEREN=".frieren/skills"
fi

# 显示使用说明
show_usage() {
    cat << EOF
使用方法: $0 [editor]

支持的编辑器:
  kiro      - 生成到 .kiro/steering/memory-integration.md
  frieren   - 生成到 .frieren/rules/memory-integration.md
  all       - 生成所有编辑器的版本（默认）

示例:
  $0           # 生成所有版本
  $0 kiro      # 只生成 Kiro 版本
  $0 frieren   # 只生成 Frieren 版本

EOF
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

# 主函数
main() {
    local editor="${1:-all}"
    
    case "$editor" in
        "kiro")
            echo "📝 生成 Kiro 版本..."
            generate_kiro
            ;;
        "frieren")
            echo "📝 生成 Frieren 版本..."
            generate_frieren
            ;;
        "all")
            echo "📝 生成所有编辑器版本..."
            generate_kiro
            generate_frieren
            ;;
        "-h"|"--help")
            show_usage
            exit 0
            ;;
        *)
            echo "❌ 未知的编辑器: $editor"
            echo ""
            show_usage
            exit 1
            ;;
    esac
    
    echo ""
    echo "✨ 生成完成！"
}

# 执行主函数
main "$@"
