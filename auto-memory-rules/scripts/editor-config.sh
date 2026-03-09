#!/bin/bash
# 编辑器配置映射表
# 定义不同编辑器的 rules 输出配置

# 获取编辑器配置
get_editor_config() {
    local editor="$1"
    
    case "$editor" in
        "kiro")
            echo "output_dir:.kiro/steering"
            echo "file_prefix:"
            echo "file_suffix:-rules.md"
            echo "use_frontmatter:true"
            echo "frontmatter_type:kiro"
            echo "multi_file:true"
            ;;
        "frieren")
            echo "output_dir:.frieren/rules"
            echo "file_prefix:"
            echo "file_suffix:-rules.md"
            echo "use_frontmatter:true"
            echo "frontmatter_type:frieren"
            echo "multi_file:true"
            ;;
        "cursor")
            echo "output_dir:."
            echo "file_prefix:"
            echo "file_suffix:.cursorrules"
            echo "use_frontmatter:false"
            echo "frontmatter_type:none"
            echo "multi_file:false"
            ;;
        "windsurf")
            echo "output_dir:."
            echo "file_prefix:"
            echo "file_suffix:.windsurfrules"
            echo "use_frontmatter:false"
            echo "frontmatter_type:none"
            echo "multi_file:false"
            ;;
        *)
            echo "error:Unknown editor: $editor"
            return 1
            ;;
    esac
}

# 获取 Kiro frontmatter
get_kiro_frontmatter() {
    local category_key="$1"
    local category_display="$2"
    
    # 根据 category 生成场景描述
    local scene_desc
    case "$category_key" in
        api)
            scene_desc="在定义 API 路由、调用接口、编写 API 文档时应用"
            ;;
        types)
            scene_desc="在定义 TypeScript 类型、接口、泛型时应用"
            ;;
        component)
            scene_desc="在开发 React 组件、设计组件 API 时应用"
            ;;
        hook)
            scene_desc="在开发自定义 Hook、封装状态逻辑时应用"
            ;;
        state)
            scene_desc="在设计状态管理、处理数据流时应用"
            ;;
        pattern)
            scene_desc="在进行架构设计、选择设计模式时应用"
            ;;
        convention)
            scene_desc="在编写代码、命名变量、组织文件时应用"
            ;;
        quality)
            scene_desc="在代码审查、重构优化时应用"
            ;;
        workflow)
            scene_desc="在开发流程、调试排查、问题解决时应用"
            ;;
        other)
            scene_desc="在相关场景中应用"
            ;;
    esac
    
    cat << EOF
---
inclusion: always
description: $scene_desc
---

EOF
}

# 获取 Frieren frontmatter
get_frieren_frontmatter() {
    local category_key="$1"
    local category_display="$2"
    
    # 根据 category 生成场景描述
    local scene_desc
    case "$category_key" in
        api)
            scene_desc="在定义 API 路由、调用接口、编写 API 文档时应用"
            ;;
        types)
            scene_desc="在定义 TypeScript 类型、接口、泛型时应用"
            ;;
        component)
            scene_desc="在开发 React 组件、设计组件 API 时应用"
            ;;
        hook)
            scene_desc="在开发自定义 Hook、封装状态逻辑时应用"
            ;;
        state)
            scene_desc="在设计状态管理、处理数据流时应用"
            ;;
        pattern)
            scene_desc="在进行架构设计、选择设计模式时应用"
            ;;
        convention)
            scene_desc="在编写代码、命名变量、组织文件时应用"
            ;;
        quality)
            scene_desc="在代码审查、重构优化时应用"
            ;;
        workflow)
            scene_desc="在开发流程、调试排查、问题解决时应用"
            ;;
        other)
            scene_desc="在相关场景中应用"
            ;;
    esac
    
    cat << EOF
---
agentRequested: true
description: "$scene_desc"
---

EOF
}

# 解析配置值
parse_config() {
    local config="$1"
    local key="$2"
    echo "$config" | grep "^$key:" | cut -d: -f2-
}

# 支持的编辑器列表
list_supported_editors() {
    echo "kiro"
    echo "frieren"
    echo "cursor"
    echo "windsurf"
}
