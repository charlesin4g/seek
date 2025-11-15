import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/env.dart';
import '../widgets/section_card.dart';
import '../widgets/form_field.dart';
import '../config/app_colors.dart';
import '../widgets/security_icons.dart';
import '../utils/responsive.dart';
// Import the main app widget
import '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(
    text: Env.useTestDefaultLogin ? 'admin' : '',
  );
  final _passwordController = TextEditingController(
    text: Env.useTestDefaultLogin ? 'seek' : '',
  );
  final _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight, // 使用新的背景色
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: Responsive.responsivePadding(context), // 使用响应式间距
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Title
                Container(
                  width: Responsive.value(context,
                    small: 100, // 小屏手机使用100px
                    medium: 120, // 标准手机使用120px
                    large: 140, // 大屏手机使用140px
                  ),
                  height: Responsive.value(context,
                    small: 100,
                    medium: 120,
                    large: 140,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient, // 使用渐变背景
                    borderRadius: BorderRadius.circular(Responsive.value(context,
                      small: 50, // 小屏手机圆角50px
                      medium: 60, // 标准手机圆角60px
                      large: 70, // 大屏手机圆角70px
                    )),
                    boxShadow: [AppShadows.light], // 添加柔和阴影
                  ),
                  child: Icon(
                    Icons.hiking,
                    size: Responsive.value(context,
                      small: 50, // 小屏手机图标50px
                      medium: 60, // 标准手机图标60px
                      large: 70, // 大屏手机图标70px
                    ),
                    color: AppColors.textWhite,
                  ),
                ),
                SizedBox(height: Responsive.value(context,
                  small: 24, // 小屏手机使用24px间距
                  medium: 32, // 标准手机使用32px间距
                  large: 40, // 大屏手机使用40px间距
                )),
                
                // App Name
                Text(
                  'Seek',
                  style: TextStyle(
                    fontSize: Responsive.value(context,
                      small: AppFontSizes.titleLarge, // 小屏手机使用24px
                      medium: AppFontSizes.titleLarge + 8, // 标准手机使用32px
                      large: AppFontSizes.titleLarge + 12, // 大屏手机使用36px
                    ),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDarkBlue,
                  ),
                ),
                SizedBox(height: Responsive.value(context,
                  small: 6,
                  medium: 8,
                  large: 10,
                )),
                Text(
                  '见山',
                  style: TextStyle(
                    fontSize: Responsive.value(context,
                      small: AppFontSizes.bodyLarge, // 小屏手机使用16px
                      medium: AppFontSizes.subtitle, // 标准手机使用18px
                      large: AppFontSizes.subtitle + 2, // 大屏手机使用20px
                    ),
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: Responsive.value(context,
                  small: 36,
                  medium: 48,
                  large: 60,
                )),

                // Login Form
                SectionCard(
                  title: '登录',
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomFormField(
                            label: '用户名',
                            controller: _usernameController,
                            hintText: '请输入用户名',
                            icon: Icons.person_outline,
                          ),
                          SizedBox(height: Responsive.value(context,
                            small: 12, // 小屏手机使用12px间距
                            medium: 16, // 标准手机使用16px间距
                            large: 20, // 大屏手机使用20px间距
                          )),
                          _buildPasswordField(),
                          SizedBox(height: Responsive.value(context,
                            small: 20,
                            medium: 24,
                            large: 28,
                          )),
                          _buildLoginButton(),
                          SizedBox(height: Responsive.value(context,
                            small: 12,
                            medium: 16,
                            large: 20,
                          )),
                          // 安全提示
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SecurityIcon(
                                icon: Icons.shield_outlined,
                                tooltip: '您的登录信息已加密保护',
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '安全登录',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: Responsive.value(context,
                                    small: AppFontSizes.body - 1, // 小屏手机使用13px
                                    medium: AppFontSizes.body, // 标准手机使用14px
                                    large: AppFontSizes.bodyLarge, // 大屏手机使用16px
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: Responsive.value(context,
                  small: 12,
                  medium: 16,
                  large: 20,
                )),
              
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            '密码',
            style: TextStyle(
              fontSize: AppFontSizes.bodyLarge, // 16px
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: '请输入密码',
              hintStyle: TextStyle(color: AppColors.textTertiary),
              border: OutlineInputBorder(
                borderRadius: AppBorderRadius.medium, // 6px圆角
                borderSide: BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppBorderRadius.medium,
                borderSide: BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppBorderRadius.medium,
                borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
              ),
              contentPadding: AppSpacing.horizontal, // 使用统一内边距
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入密码';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: Responsive.responsiveButtonHeight(context), // 使用响应式按钮高度
      child: FilledButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondaryGreen, // 使用浅绿色
          foregroundColor: AppColors.textWhite,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.medium, // 6px圆角
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                '登录',
                style: TextStyle(
                  fontSize: Responsive.value(context,
                    small: AppFontSizes.body, // 小屏手机使用14px
                    medium: AppFontSizes.bodyLarge, // 标准手机使用16px
                    large: AppFontSizes.bodyLarge + 2, // 大屏手机使用18px
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Debug: print username and password
      // NOTE: Remove in production
      // ignore: avoid_print
      print('Login attempt -> username: ${_usernameController.text.trim()}, password: ${_passwordController.text.trim()}');
      
      final success = await _authService.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainApp()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text('登录失败，请检查用户名和密码'),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: AppBorderRadius.medium,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text('登录出错: $e'),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppBorderRadius.medium,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}


