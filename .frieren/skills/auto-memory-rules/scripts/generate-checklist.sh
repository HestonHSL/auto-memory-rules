#!/bin/bash
# Auto-Memory-Rules Checklist 生成器
# 从 memory/rules/ 自动生成代码审查 checklist

# 获取脚本所在目录和项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
RULES_DIR="$SCRIPT_DIR/../memory/rules"
OUTPUT_FILE="$SCRIPT_DIR/../memory/CHECKLIST.md"

echo "📖 读取规则文件..."

# 检查 rules 目录是否存在
if [ ! -d "$RULES_DIR" ]; then
    echo "⚠️  Rules 目录不存在，创建中..."
    mkdir -p "$RULES_DIR"
fi

# 统计规则数量
rule_count=$(find "$RULES_DIR" -name "*.md" | wc -l | tr -d ' ')
echo "✅ 找到 $rule_count 条规则"

echo "📝 生成 checklist..."

# 生成 checklist 头部
cat > "$OUTPUT_FILE" << 'EOF'
# 记忆系统自检清单

> 此文件自动生成，请勿手动编辑
> 运行 `bash .kiro/skills/auto-memory-rules/scripts/generate-checklist.sh` 重新生成

EOF

echo "生成时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$OUTPUT_FILE"
echo "规则总数: $rule_count" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

cat >> "$OUTPUT_FILE" << 'EOF'
## 使用说明

在生成代码前，根据任务类型查看相关类别的检查点，确保不会重复历史错误。

**使用方式**：
- 在对话开始时：AI 会自动加载相关规则
- 手动检查：根据下方分类查看相关检查点
- 生成代码后：对照 checklist 进行自检

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

# 遍历每个 category
for category_key in $CATEGORIES; do
    category_name=$(get_category_name "$category_key")
    has_rules=false
    
    # 临时文件存储该 category 的内容
    temp_file=$(mktemp)
    
    # 按优先级处理
    for priority in "high" "medium" "low"; do
        priority_label=""
        case $priority in
            high) priority_label="🔴 高优先级" ;;
            medium) priority_label="🟡 中优先级" ;;
            low) priority_label="🟢 低优先级" ;;
        esac
        
        has_priority_rules=false
        priority_content=""
        
        # 查找该 category 和 priority 的规则
        for rule in "$RULES_DIR"/*.md; do
            if [ -f "$rule" ]; then
                # 检查 category
                if grep -q "^category:.*$category_key" "$rule"; then
                    # 检查 priority
                    if grep -q "^priority:.*$priority" "$rule"; then
                        has_rules=true
                        has_priority_rules=true
                        
                        # 提取标题
                        title=$(grep "^# " "$rule" | head -1 | sed 's/^# //')
                        
                        # 提取标签
                        tags=$(grep "^tags:" "$rule" | sed 's/^tags: *\[//' | sed 's/\]//' | sed 's/, */ | /g')
                        
                        priority_content+="#### $title\n\n"
                        
                        if [ -n "$tags" ]; then
                            priority_content+="**标签**: $tags\n\n"
                        fi
                        
                        # 提取检查点
                        checkpoints=$(sed -n '/## 检查点/,/^## /p' "$rule" | grep "^- \[ \]" || sed -n '/## 自检清单/,/^## /p' "$rule" | grep "^- \[ \]")
                        
                        if [ -n "$checkpoints" ]; then
                            priority_content+="**检查点**:\n"
                            priority_content+="$checkpoints\n\n"
                        else
                            filename=$(basename "$rule")
                            priority_content+="*无具体检查点，请查看规则文件: \`$filename\`*\n\n"
                        fi
                    fi
                fi
            fi
        done
        
        # 如果该优先级有规则，写入临时文件
        if [ "$has_priority_rules" = true ]; then
            echo -e "### $priority_label\n" >> "$temp_file"
            echo -e "$priority_content" >> "$temp_file"
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
echo "## 其他" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

for rule in "$RULES_DIR"/*.md; do
    if [ -f "$rule" ]; then
        # 检查是否没有 category 或 category 不在已知列表中
        if ! grep -q "^category:" "$rule" || ! grep -E "^category:.*(api|types|component|hook|state|pattern|convention|quality|workflow)" "$rule"; then
            title=$(grep "^# " "$rule" | head -1 | sed 's/^# //')
            priority=$(grep "^priority:" "$rule" | sed 's/^priority: *//')
            
            echo "### $title" >> "$OUTPUT_FILE"
            
            if [ -n "$priority" ]; then
                echo "" >> "$OUTPUT_FILE"
                echo "**优先级**: $priority" >> "$OUTPUT_FILE"
            fi
            
            checkpoints=$(sed -n '/## 检查点/,/^## /p' "$rule" | grep "^- \[ \]" || sed -n '/## 自检清单/,/^## /p' "$rule" | grep "^- \[ \]")
            
            if [ -n "$checkpoints" ]; then
                echo "" >> "$OUTPUT_FILE"
                echo "$checkpoints" >> "$OUTPUT_FILE"
            fi
            
            echo "" >> "$OUTPUT_FILE"
        fi
    fi
done

# 添加快速索引
echo "---" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "## 快速索引" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

for category_key in $CATEGORIES; do
    category_name=$(get_category_name "$category_key")
    count=$(grep -l "^category:.*$category_key" "$RULES_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
    if [ "$count" -gt 0 ]; then
        echo "- [$category_name](#${category_name// /-}) ($count 条规则)" >> "$OUTPUT_FILE"
    fi
done

echo "" >> "$OUTPUT_FILE"

echo "✨ Checklist 已生成: $OUTPUT_FILE"
echo ""
echo "📋 统计信息:"

# 统计各 category 的规则数量
for category_key in $CATEGORIES; do
    category_name=$(get_category_name "$category_key")
    count=$(grep -l "^category:.*$category_key" "$RULES_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
    if [ "$count" -gt 0 ]; then
        high=$(grep -l "^priority:.*high" $(grep -l "^category:.*$category_key" "$RULES_DIR"/*.md 2>/dev/null) 2>/dev/null | wc -l | tr -d ' ')
        medium=$(grep -l "^priority:.*medium" $(grep -l "^category:.*$category_key" "$RULES_DIR"/*.md 2>/dev/null) 2>/dev/null | wc -l | tr -d ' ')
        low=$(grep -l "^priority:.*low" $(grep -l "^category:.*$category_key" "$RULES_DIR"/*.md 2>/dev/null) 2>/dev/null | wc -l | tr -d ' ')
        echo "  $category_name: $count 条 (高: $high, 中: $medium, 低: $low)"
    fi
done
