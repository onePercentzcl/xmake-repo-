package("spdlog-mp")
    set_homepage("https://github.com/onePercentzcl/spdlog-mp")
    set_description("Multi-process shared memory logging extension based on spdlog")
    set_license("MIT")

    set_urls("https://github.com/onePercentzcl/spdlog-mp.git")
    add_versions("main", "main")
    add_versions("v1.0.3", "18b0523")
    add_versions("v1.0.2", "86c38586f799e0b32394f36fb1f0a5c1518b98c9")
    add_versions("v1.0.1", "7965092eac7c26f8624b38a7963004e319c92ddc")

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
    end)

    on_install(function (package)
        local configs = {}
        
        -- 强制使用 release 模式编译
        configs.mode = "release"
        
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
        
        -- 显式添加 NDEBUG 定义（确保 release 模式格式生效）
        package:add("defines", "NDEBUG")
        
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
