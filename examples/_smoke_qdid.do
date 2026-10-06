* _smoke_qdid.do — 冒烟测试：qdid 骨架可加载 + Stata 环境正常
clear all
set more off
display "Stata version: " c(stata_version)

* 1) qdid 是否能被找到
adopath + "D:\OpenCode\qdid"
capture which qdid
display "which qdid rc = " _rc
if _rc == 0 {
    display as result "SMOKE PASS: qdid found"
}
else {
    display as error "SMOKE FAIL: qdid not found"
}

* 2) 调用骨架命令，确认能进 program（预期 exit 199）
capture noisily qdid y, unit(id) time(t) treat(d) quantiles(0.5)
display "qdid call rc = " _rc
if _rc == 199 {
    display as result "SMOKE PASS: qdid skeleton reached (exit 199 as expected)"
}

* 3) contdid 仍在
adopath + "D:\OpenCode\contdid"
capture which contdid
display "which contdid rc = " _rc
if _rc == 0 {
    display as result "SMOKE PASS: contdid found"
}

* 4) 基础环境
sysuse auto, clear
display as result "SMOKE PASS: sysuse auto ok, N = " _N
display as result "SMOKE DONE"
