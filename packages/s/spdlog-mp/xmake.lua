package("spdlog-mp")
    set_homepage("https://github.com/onePercentzcl/spdlog-mp")
    set_description("Multi-process shared memory logging extension based on spdlog")
    set_license("MIT")

    set_urls("https://github.com/onePercentzcl/spdlog-mp.git")
    add_versions("main", "main")
    add_versions("v0.0.2", "b37d4aa5bad8440d86260cacdb306c071bf1cc03")
    add_versions("v0.0.1", "af23d457febc7e40792bf8e3dcf2feeded30b919")

    add_configs("enable_multiprocess", {description = "Enable multiprocess shared memory support", default = true, type = "boolean"})
    add_configs("header_only", {description = "Use header only version", default = false, type = "boolean"})
    add_configs("std_format", {description = "Use std::format instead of fmt", default = false, type = "boolean"})
    add_configs("fmt_external", {description = "Use external fmt library", default = false, type = "boolean"})
    add_configs("fmt_external_ho", {description = "Use external fmt header-only library", default = false, type = "boolean"})
    add_configs("noexcept", {description = "Compile with -fno-exceptions", default = false, type = "boolean"})

    add_defines("SPDLOG_COMPILED_LIB")

    if is_plat("linux", "macosx", "bsd") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:config("header_only") then
            package:set("kind", "library", {headeronly = true})
            package:add("defines", "SPDLOG_HEADER_ONLY")
        end
        if package:config("enable_multiprocess") then
            package:add("defines", "SPDLOG_ENABLE_MULTIPROCESS")
        end
        if package:config("std_format") then
            package:add("defines", "SPDLOG_USE_STD_FORMAT")
        end
        if package:config("fmt_external") then
            package:add("deps", "fmt")
            package:add("defines", "SPDLOG_FMT_EXTERNAL")
        end
        if package:config("fmt_external_ho") then
            package:add("deps", "fmt", {configs = {header_only = true}})
            package:add("defines", "SPDLOG_FMT_EXTERNAL_HO")
        end
        if package:config("noexcept") then
            package:add("defines", "SPDLOG_NO_EXCEPTIONS")
        end
        -- NDEBUG 由 xmake 的 mode.release 规则自动添加
        -- 不需要在包配置中手动处理
    end)

    on_install(function (package)
        local configs = {}
        
        -- 根据用户项目的编译模式设置库的编译模式
        -- 这样 .cpp 文件中的 #ifdef NDEBUG 才能正确工作
        if package:is_debug() then
            configs.mode = "debug"
        else
            configs.mode = "release"
        end
        
        if package:config("enable_multiprocess") then
            configs.enable_multiprocess = true
        end
        if package:config("std_format") then
            configs.use_std_format = true
        end
        if package:config("fmt_external") then
            configs.fmt_external = true
        end
        if package:config("fmt_external_ho") then
            configs.fmt_external_ho = true
        end
        if package:config("noexcept") then
            configs.no_exceptions = true
        end
        
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <spdlog/spdlog.h>
            void test() {
                spdlog::info("hello world");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
