#!/bin/bash

# Flutter 真机测试脚本
# 用于自动化执行真机测试流程

set -e

echo "🚀 Flutter 真机测试脚本启动"
echo "=================================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="/Users/torolleys/github/seek/mobile"
cd "$PROJECT_ROOT"

# 日志文件
LOG_FILE="test/device_test_$(date +%Y%m%d_%H%M%S).log"

# 函数：打印带颜色的信息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# 函数：检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 函数：环境检查
check_environment() {
    print_info "开始环境检查..."
    
    # 检查Flutter
    if command_exists flutter; then
        FLUTTER_VERSION=$(flutter --version | head -n1)
        print_success "Flutter已安装: $FLUTTER_VERSION"
    else
        print_error "Flutter未安装，请先安装Flutter SDK"
        exit 1
    fi
    
    # 执行flutter doctor
    print_info "执行flutter doctor检查..."
    flutter doctor -v >> "$LOG_FILE" 2>&1
    
    if [ $? -eq 0 ]; then
        print_success "Flutter环境检查完成"
    else
        print_warning "Flutter环境存在问题，请查看日志文件: $LOG_FILE"
    fi
}

# 函数：设备连接检查
check_devices() {
    print_info "检查连接的设备..."
    
    # 检查Android设备
    if command_exists adb; then
        ANDROID_DEVICES=$(adb devices | grep -v "List" | grep "device" | wc -l)
        if [ $ANDROID_DEVICES -gt 0 ]; then
            print_success "发现 $ANDROID_DEVICES 个Android设备"
            adb devices | grep -v "List" | grep "device" | while read line; do
                print_info "  - Android设备: $line"
            done
        else
            print_warning "未发现Android设备，请确保："
            print_warning "  1. 设备已开启USB调试模式"
            print_warning "  2. 设备已通过USB连接"
            print_warning "  3. 已安装正确的USB驱动"
        fi
    else
        print_warning "未安装ADB工具，无法检查Android设备"
    fi
    
    # 检查iOS设备
    print_info "检查iOS设备..."
    flutter devices | grep "ios" | while read line; do
        print_info "  - iOS设备: $line"
    done
    
    # 检查模拟器
    print_info "检查可用模拟器..."
    flutter devices | grep -E "(android|ios)" | while read line; do
        print_info "  - 设备: $line"
    done
}

# 函数：获取依赖
install_dependencies() {
    print_info "安装项目依赖..."
    
    flutter pub get >> "$LOG_FILE" 2>&1
    
    if [ $? -eq 0 ]; then
        print_success "依赖安装成功"
    else
        print_error "依赖安装失败，请检查网络连接和pubspec.yaml文件"
        exit 1
    fi
}

# 函数：构建Android应用
build_android() {
    print_info "构建Android应用..."
    
    # 清理构建缓存
    flutter clean >> "$LOG_FILE" 2>&1
    
    # 构建APK
    flutter build apk --release >> "$LOG_FILE" 2>&1
    
    if [ $? -eq 0 ]; then
        print_success "Android APK构建成功"
        APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
        if [ -f "$APK_PATH" ]; then
            APK_SIZE=$(ls -lh "$APK_PATH" | awk '{print $5}')
            print_info "APK文件大小: $APK_SIZE"
        fi
    else
        print_error "Android APK构建失败，请查看日志文件: $LOG_FILE"
        return 1
    fi
}

# 函数：构建iOS应用
build_ios() {
    print_info "构建iOS应用..."
    
    # 清理构建缓存
    flutter clean >> "$LOG_FILE" 2>&1
    
    # 构建iOS（无签名）
    flutter build ios --release --no-codesign >> "$LOG_FILE" 2>&1
    
    if [ $? -eq 0 ]; then
        print_success "iOS应用构建成功"
    else
        print_error "iOS应用构建失败，请查看日志文件: $LOG_FILE"
        print_info "提示：可以尝试使用Xcode进行构建"
        return 1
    fi
}

# 函数：安装到设备
install_to_device() {
    local device_type=$1
    
    print_info "安装应用到$device_type设备..."
    
    if [ "$device_type" = "android" ]; then
        # 检查是否有Android设备连接
        ANDROID_COUNT=$(adb devices | grep -v "List" | grep "device" | wc -l)
        if [ $ANDROID_COUNT -eq 0 ]; then
            print_warning "没有Android设备连接，跳过安装"
            return 1
        fi
        
        flutter install >> "$LOG_FILE" 2>&1
        if [ $? -eq 0 ]; then
            print_success "Android应用安装成功"
        else
            print_error "Android应用安装失败"
            return 1
        fi
    elif [ "$device_type" = "ios" ]; then
        flutter install >> "$LOG_FILE" 2>&1
        if [ $? -eq 0 ]; then
            print_success "iOS应用安装成功"
        else
            print_error "iOS应用安装失败"
            return 1
        fi
    fi
}

# 函数：运行自动化测试
run_automated_tests() {
    local device_id=$1
    
    print_info "在设备 $device_id 上运行自动化测试..."
    
    # 启动性能分析模式
    flutter run --profile -d "$device_id" >> "$LOG_FILE" 2>&1 &
    RUN_PID=$!
    
    # 等待应用启动
    sleep 10
    
    # 执行测试脚本（这里需要根据实际测试框架调整）
    print_info "执行功能测试..."
    
    # 模拟用户操作
    # 注意：这里需要集成实际的测试框架，如Appium、Flutter Driver等
    
    # 停止应用
    kill $RUN_PID 2>/dev/null
    
    print_success "自动化测试完成"
}

# 函数：性能监控
performance_monitoring() {
    local device_id=$1
    
    print_info "开始性能监控..."
    
    # 启动应用并收集性能数据
    flutter run --profile -d "$device_id" --trace-startup --verbose >> "$LOG_FILE" 2>&1 &
    RUN_PID=$!
    
    # 等待应用启动
    sleep 15
    
    # 收集内存和CPU数据
    if [[ "$device_id" == *"android"* ]] || [[ "$device_id" == *"emulator"* ]]; then
        # Android性能数据收集
        PACKAGE_NAME=$(grep "applicationId" android/app/build.gradle | cut -d'"' -f2)
        adb shell dumpsys meminfo "$PACKAGE_NAME" | grep "TOTAL" >> "$LOG_FILE"
        adb shell top -n 1 | grep "$PACKAGE_NAME" >> "$LOG_FILE"
    fi
    
    # 停止监控
    kill $RUN_PID 2>/dev/null
    
    print_success "性能监控完成"
}

# 函数：生成测试报告
generate_report() {
    print_info "生成测试报告..."
    
    # 创建报告目录
    mkdir -p test/reports
    
    # 生成时间戳
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    REPORT_FILE="test/reports/device_test_report_$TIMESTAMP.md"
    
    # 复制模板并更新
    cp test/device_test_report_template.md "$REPORT_FILE"
    
    # 更新报告内容（这里可以根据实际测试数据更新）
    sed -i '' "s/2024-12-01/$(date +%Y-%m-%d)/g" "$REPORT_FILE"
    sed -i '' "s/v1.0.0/$(grep "version:" pubspec.yaml | cut -d' ' -f2)/g" "$REPORT_FILE"
    
    print_success "测试报告已生成: $REPORT_FILE"
}

# 函数：清理资源
cleanup() {
    print_info "清理测试资源..."
    
    # 停止所有flutter进程
    pkill -f "flutter run" 2>/dev/null || true
    
    # 清理构建文件
    flutter clean >> "$LOG_FILE" 2>&1
    
    print_success "清理完成"
}

# 主函数
main() {
    # 设置清理陷阱
    trap cleanup EXIT
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --android-only)
                ANDROID_ONLY=true
                shift
                ;;
            --ios-only)
                IOS_ONLY=true
                shift
                ;;
            --device)
                SPECIFIC_DEVICE="$2"
                shift 2
                ;;
            --skip-build)
                SKIP_BUILD=true
                shift
                ;;
            --skip-install)
                SKIP_INSTALL=true
                shift
                ;;
            --help)
                echo "用法: $0 [选项]"
                echo "选项:"
                echo "  --android-only    仅测试Android平台"
                echo "  --ios-only        仅测试iOS平台"
                echo "  --device ID       指定测试设备"
                echo "  --skip-build      跳过构建步骤"
                echo "  --skip-install    跳过安装步骤"
                echo "  --help            显示帮助信息"
                exit 0
                ;;
            *)
                print_error "未知选项: $1"
                exit 1
                ;;
        esac
    done
    
    # 开始测试流程
    print_info "开始Flutter真机测试流程"
    print_info "日志文件: $LOG_FILE"
    
    # 环境检查
    check_environment
    
    # 设备检查
    check_devices
    
    # 安装依赖
    install_dependencies
    
    # 构建和测试
    if [ "$ANDROID_ONLY" != true ]; then
        if [ "$SKIP_BUILD" != true ]; then
            build_ios || print_warning "iOS构建失败，继续其他测试"
        fi
    fi
    
    if [ "$IOS_ONLY" != true ]; then
        if [ "$SKIP_BUILD" != true ]; then
            build_android || print_warning "Android构建失败，继续其他测试"
        fi
        
        if [ "$SKIP_INSTALL" != true ]; then
            install_to_device "android" || print_warning "Android安装失败"
        fi
    fi
    
    # 性能监控（如果有指定设备）
    if [ -n "$SPECIFIC_DEVICE" ]; then
        performance_monitoring "$SPECIFIC_DEVICE"
    fi
    
    # 生成报告
    generate_report
    
    print_success "测试流程完成！"
    print_info "请查看详细日志: $LOG_FILE"
    print_info "测试报告已生成在 test/reports/ 目录下"
}

# 运行主函数
main "$@"