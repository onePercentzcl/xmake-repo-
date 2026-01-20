# My xmake-repo

个人 xmake 包仓库。

## 使用方法

在你的项目 `xmake.lua` 中添加：

```lua
add_repositories("my-repo https://github.com/onePercentzcl/xmake-repo")
add_requires("spdlog-mp", {configs = {enable_multiprocess = true}})

target("myapp")
    set_kind("binary")
    set_languages("c++17")
    add_files("*.cpp")
    add_packages("spdlog-mp")
```

## 包列表

### spdlog-mp

基于 spdlog 的多进程共享内存日志扩展。

- 主页: https://github.com/onePercentzcl/spdlog-mp
- 许可证: MIT

**配置选项：**

| 选项 | 默认值 | 说明 |
|------|--------|------|
| enable_multiprocess | true | 启用多进程共享内存支持 |
| header_only | false | 使用 header-only 版本 |
| std_format | false | 使用 std::format 替代 fmt |
| fmt_external | false | 使用外部 fmt 库 |
| noexcept | false | 禁用异常 |

**示例：**

```lua
add_requires("spdlog-mp", {configs = {enable_multiprocess = true}})
```
