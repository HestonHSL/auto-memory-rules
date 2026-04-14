#!/bin/bash
# Auto-Memory-Rules 规则生成器 - Kiro 单平台版本
# 从 memory 目录读取记忆文件，生成 Kiro 规则文件到 .kiro/steering/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULES_DIR="$SCRIPT_DIR/../memory"

# 动态检测项目根目录
if echo "$SCRIPT_DIR" | grep -q "/\.kiro/skills/"; then
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
else
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

# Kiro 平台硬编码配置
OUTPUT_DIR="$PROJECT_ROOT/.kiro/steering"
FILE_SUFFIX="-rules.md"

# 获取 category 显示名称
get_category_display_name() {
    case "$1" in
        api) echo "API 相关" ;;
        types) echo "类型定义" ;;
        component) echo "组件开发" ;;
        hook) echo "Hook 开发" ;;
        state) echo "状态管理" ;;
        testing) echo "测试工程" ;;
        security) echo "安全规范" ;;
        pattern) echo "设计模式" ;;
        convention) echo "编码规范" ;;
        quality) echo "代码质量" ;;
        workflow) echo "工作流程" ;;
        general) echo "通用规则" ;;
        other) echo "其他" ;;
    esac
}

# 生成 Kiro frontmatter
get_kiro_frontmatter() {
    local category_key="$1"
    local category_display="$2"
    
    local description=""
    case "$category_key" in
        api) description="在定义 API 路由、调用接口、编写 API 文档时应用" ;;
        types) description="在定义 TypeScript 类型、接口、泛型时应用" ;;
        component) description="在开发 React 组件、编写 JSX、设计 Props 时应用" ;;
        hook) description="在开发自定义 Hook、封装 useXxx 时应用" ;;
        state) description="在设计状态管理、数据流、状态恢复时应用" ;;
        testing) description="在编写单元测试、集成测试、E2E 测试时应用" ;;
        security) description="在实现认证鉴权、权限模型、输入校验时应用" ;;
        pattern) description="在应用设计模式、架构模式、组织代码时应用" ;;
        convention) description="在命名、格式化、编写注释时应用" ;;
        quality) description="在优化可维护性、性能、遵循最佳实践时应用" ;;
        workflow) description="在开发流程、调试方法、问题排查时应用" ;;
        general) description="跨领域通用规则，在所有开发场景中应用" ;;
        other) description="其他未分类的规则" ;;
    esac
    
    cat << EOF
---
inclusion: always
description: $description
---

EOF
}

# 提取规则的核心要素（去掉示例和冗余说明）
extract_rule_essentials() {
    local rule_file="$1"
    local in_frontmatter=false
    local skip_section=false
    
    while IFS= read -r line; do
        # 处理 frontmatter
        if [ "$line" = "---" ]; then
            if [ "$in_frontmatter" = false ]; then
                in_frontmatter=true
                echo "$line"
            else
                in_frontmatter=false
                echo "$line"
            fi
            continue
        fi
        
        # frontmatter 内容保留
        if [ "$in_frontmatter" = true ]; then
            echo "$line"
            continue
        fi
        
        # 跳过的章节
        if echo "$line" | grep -qE "^## (示例|相关规则|反思记录|规则来源|触发场景|优先级说明)"; then
            skip_section=true
            continue
        fi
        
        # 遇到新章节，重置跳过标记
        if echo "$line" | grep -qE "^## "; then
            skip_section=false
        fi
        
        # 如果在跳过的章节中，继续跳过
        if [ "$skip_section" = true ]; then
            continue
        fi
        
        # 保留标题、核心原则、具体要求、检查点
        if echo "$line" | grep -qE "^#|^## (核心原则|具体要求|检查点)"; then
            echo "$line"
            continue
        fi
        
        # 检查点部分
        if echo "$line" | grep -qE "^- \[ \]"; then
            echo "$line"
            continue
        fi
        
        # 保留列表项（具体要求）
        if echo "$line" | grep -qE "^- "; then
            echo "$line"
            continue
        fi
        
        # 保留普通段落
        if [ -n "$line" ]; then
            echo "$line"
        fi
    done < "$rule_file"
}

# 生成文件头部
generate_header() {
    local category_display="$1"
    local category_key="$2"
    
    # 生成 Kiro frontmatter
    get_kiro_frontmatter "$category_key" "$category_display"
    
    cat << EOF
# 记忆系统 - $category_display

> 此文件自动生成，请勿手动编辑
> 运行 \`bash scripts/generate-rules.sh\` 重新生成

---

EOF
}

# 生成规则文件
generate_rules() {
    local categories="api types component hook state testing security pattern convention quality workflow general other"
    
    for category_key in $categories; do
        local category_display=$(get_category_display_name "$category_key")
        local output_file="$OUTPUT_DIR/${category_key}${FILE_SUFFIX}"
        local temp_file=$(mktemp)
        local has_rules=false
        
        # 生成文件头部
        generate_header "$category_display" "$category_key" > "$temp_file"
        
        # 查找该 category 的规则
        for rule in "$RULES_DIR"/*.md; do
            # 跳过自动生成的文件
            local basename=$(basename "$rule")
            if [ "$basename" = "index.md" ] || [ "$basename" = "CHECKLIST.md" ]; then
                continue
            fi
            
            if [ -f "$rule" ]; then
                if [ "$category_key" = "other" ]; then
                    # 未分类或不在标准列表中（包括已移除的 backend、database、infra）
                    if ! grep -q "^category:" "$rule" || ! grep -E "^category:.*(api|types|component|hook|state|testing|security|pattern|convention|quality|workflow|general)" "$rule"; then
                        has_rules=true
                        extract_rule_essentials "$rule" >> "$temp_file"
                        echo -e "\n---\n" >> "$temp_file"
                    fi
                else
                    # 标准 category
                    if grep -q "^category:.*$category_key" "$rule"; then
                        has_rules=true
                        extract_rule_essentials "$rule" >> "$temp_file"
                        echo -e "\n---\n" >> "$temp_file"
                    fi
                fi
            fi
        done
        
        # 如果该 category 有规则，写入输出文件
        if [ "$has_rules" = true ]; then
            mv "$temp_file" "$output_file"
            echo "  ✅ $output_file"
        else
            rm -f "$temp_file"
        fi
    done
}

# 主函数
main() {
    echo "📖 读取记忆文件..."
    
    # 检查 memory 目录是否存在
    if [ ! -d "$RULES_DIR" ]; then
        echo "⚠️  Memory 目录不存在: $RULES_DIR"
        exit 1
    fi
    
    # 统计记忆数量
    rule_count=$(find "$RULES_DIR" -name "*.md" -not -name "index.md" -not -name "CHECKLIST.md" | wc -l | tr -d ' ')
    echo "✅ 找到 $rule_count 条记忆"
    
    if [ "$rule_count" -eq 0 ]; then
        echo "⚠️  没有记忆文件，跳过生成"
        exit 0
    fi
    
    # 创建输出目录
    mkdir -p "$OUTPUT_DIR"
    
    echo "📝 生成 Kiro 规则文件..."
    generate_rules
    
    echo ""
    echo "✨ 规则已生成到: $OUTPUT_DIR"
    echo ""
    
    echo "📋 统计信息:"
    # 统计各 category 的规则数量
    local categories="api types component hook state testing security pattern convention quality workflow general other"
    for category_key in $categories; do
        local category_display=$(get_category_display_name "$category_key")
        local count
        
        if [ "$category_key" = "other" ]; then
            count=0
            for rule in "$RULES_DIR"/*.md; do
                local basename=$(basename "$rule")
                if [ "$basename" = "index.md" ] || [ "$basename" = "CHECKLIST.md" ]; then
                    continue
                fi
                if [ -f "$rule" ]; then
                    if ! grep -q "^category:" "$rule" || ! grep -E "^category:.*(api|types|component|hook|state|testing|security|pattern|convention|quality|workflow|general)" "$rule"; then
                        count=$((count + 1))
                    fi
                fi
            done
        else
            count=0
            for rule in "$RULES_DIR"/*.md; do
                local basename=$(basename "$rule")
                if [ "$basename" = "index.md" ] || [ "$basename" = "CHECKLIST.md" ]; then
                    continue
                fi
                if [ -f "$rule" ] && grep -q "^category:.*$category_key" "$rule"; then
                    count=$((count + 1))
                fi
            done
        fi
        
        if [ "$count" -gt 0 ]; then
            echo "  $category_display: $count 条规则"
        fi
    done
}

# 执行主函数
main

