#!/bin/bash
# Auto-Memory-Rules Index 生成器
# 从 memory/rules/ 自动生成分类索引

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULES_DIR="$SCRIPT_DIR/../memory/rules"
OUTPUT_FILE="$SCRIPT_DIR/../memory/index.md"

echo "📖 读取规则文件..."

# 检查 rules 目录是否存在
if [ ! -d "$RULES_DIR" ]; then
    echo "⚠️  Rules 目录不存在，创建中..."
    mkdir -p "$RULES_DIR"
fi

# 统计规则数量
rule_count=$(find "$RULES_DIR" -name "*.md" | wc -l | tr -d ' ')
echo "✅ 找到 $rule_count 条规则"

echo "📝 生成索引..."

# 生成索引头部
cat > "$OUTPUT_FILE" << 'EOF'
# 记忆系统规则索引

> 此文件自动生成，请勿手动编辑
> 运行 `bash .kiro/skills/auto-memory-rules/scripts/generate-index.sh` 重新生成

EOF

echo "生成时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$OUTPUT_FILE"
echo "规则总数: $rule_count" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

cat >> "$OUTPUT_FILE" << 'EOF'
## 使用说明

此索引帮助你快速找到相关规则：
- 按 category 浏览规则
- 按 tags 搜索规则
- 按 priority 筛选规则

---

EOF

# 定义 category 映射（使用函数代替关联数组以兼容旧版 bash）
get_category_name() {
    case "$1" in
        api) echo "API 相关" ;;
        types) echo "类型定义" ;;
        component) echo "组件开发" ;;
        hook) echo "Hook 开发" ;;
        state) echo "状态管理" ;;
        pattern) echo "设计模式" ;;
        convention) echo "编码规范" ;;
        quality) echo "代码质量" ;;
        workflow) echo "工作流程" ;;
        *) echo "$1" ;;
    esac
}

# 所有 category 列表
CATEGORIES="api types component hook state pattern convention quality workflow"

# 按 category 分组
for category_key in $CATEGORIES; do
    category_name=$(get_category_name "$category_key")
    has_rules=false
    
    # 临时文件存储该 category 的内容
    temp_file=$(mktemp)
    
    # 查找该 category 的规则
    for rule in "$RULES_DIR"/*.md; do
        if [ -f "$rule" ]; then
            # 检查 category
            if grep -q "^category:.*$category_key" "$rule"; then
                has_rules=true
                
                # 提取信息
                filename=$(basename "$rule")
                title=$(grep "^# " "$rule" | head -1 | sed 's/^# //')
                priority=$(grep "^priority:" "$rule" | sed 's/^priority: *//')
                tags=$(grep "^tags:" "$rule" | sed 's/^tags: *\[//' | sed 's/\]//' | sed 's/, */ | /g')
                # 只提取 description 字段的值（在 frontmatter 中）
                description=$(grep "^description:" "$rule" | sed 's/^description: *//')
                
                # 优先级标记
                priority_icon=""
                case $priority in
                    high) priority_icon="🔴" ;;
                    medium) priority_icon="🟡" ;;
                    low) priority_icon="🟢" ;;
                esac
                
                echo "- [$priority_icon $title](rules/$filename)" >> "$temp_file"
                
                if [ -n "$description" ]; then
                    echo "  - $description" >> "$temp_file"
                fi
                
                if [ -n "$tags" ]; then
                    echo "  - 标签: $tags" >> "$temp_file"
                fi
                
                echo "" >> "$temp_file"
            fi
        fi
    done
    
    # 如果该 category 有规则，写入输出文件
    if [ "$has_rules" = true ]; then
        echo "## $category_name" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        cat "$temp_file" >> "$OUTPUT_FILE"
    fi
    
    rm -f "$temp_file"
done

# 处理未分类的规则
uncategorized_count=0
temp_file=$(mktemp)

for rule in "$RULES_DIR"/*.md; do
    if [ -f "$rule" ]; then
        # 检查是否没有 category 或 category 不在已知列表中
        if ! grep -q "^category:" "$rule" || ! grep -E "^category:.*(api|types|component|hook|state|pattern|convention|quality|workflow)" "$rule"; then
            uncategorized_count=$((uncategorized_count + 1))
            
            filename=$(basename "$rule")
            title=$(grep "^# " "$rule" | head -1 | sed 's/^# //')
            
            echo "- [$title](rules/$filename)" >> "$temp_file"
            echo "" >> "$temp_file"
        fi
    fi
done

if [ "$uncategorized_count" -gt 0 ]; then
    echo "## 未分类" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    cat "$temp_file" >> "$OUTPUT_FILE"
fi

rm -f "$temp_file"

# 添加统计信息
echo "---" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "## 统计信息" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

for category_key in $CATEGORIES; do
    category_name=$(get_category_name "$category_key")
    count=$(grep -l "^category:.*$category_key" "$RULES_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
    if [ "$count" -gt 0 ]; then
        echo "- $category_name: $count 条规则" >> "$OUTPUT_FILE"
    fi
done

if [ "$uncategorized_count" -gt 0 ]; then
    echo "- 未分类: $uncategorized_count 条规则" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"

# 添加相关文件链接
cat >> "$OUTPUT_FILE" << 'EOF'
---

## 相关文件

- [CHECKLIST.md](CHECKLIST.md) - 自检清单

EOF

echo "✨ 索引已生成: $OUTPUT_FILE"
echo ""
echo "📋 统计信息:"

# 统计各 category 的规则数量
for category_key in $CATEGORIES; do
    category_name=$(get_category_name "$category_key")
    count=$(grep -l "^category:.*$category_key" "$RULES_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
    if [ "$count" -gt 0 ]; then
        echo "  $category_name: $count 条规则"
    fi
done

if [ "$uncategorized_count" -gt 0 ]; then
    echo "  未分类: $uncategorized_count 条规则"
fi
