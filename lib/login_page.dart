import 'package:flutter/material.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool rememberMe = false;

  void login() {
    if (usernameController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username dan password harus diisi'),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => const HomePage(),
  ),
);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff1f1f1),

      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

           Container(
  width: 80,
  height: 80,
  margin: const EdgeInsets.only(bottom: 24),
  child: Image.asset(                     
    'assets/pnp.jpg',
    fit: BoxFit.contain,
  ),
),

              Container(
                width: 360,
                padding: const EdgeInsets.fromLTRB(
                  24,
                  27,
                  24,
                  25,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xffdddddd),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // USERNAME
                    const Text(
                      'Username',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xff50575e),
                      ),
                    ),

                    const SizedBox(height: 6),

                    SizedBox(
                      height: 42,
                      child: TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: Color(0xffdcdcde),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: Color(0xffdcdcde),
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: Color(0xff2271b1),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // PASSWORD
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xff50575e),
                      ),
                    ),

                    const SizedBox(height: 6),

                    SizedBox(
                      height: 42,
                      child: TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 19,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 9, 255, 0),
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: Color(0xffdcdcde),
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 53, 177, 34),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // REMEMBER ME + LOGIN
                    Row(
                      children: [

                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: rememberMe,
                            onChanged: (value) {
                              setState(() {
                                rememberMe = value ?? false;
                              });
                            },
                            side: const BorderSide(
                              color: Color(0xff8c8f94),
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        const Text(
                          'Remember Me',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xff50575e),
                          ),
                        ),

                        const Spacer(),

                        SizedBox(
                          height: 31,
                          child: ElevatedButton(
                            onPressed: login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 2, 255, 15),
                              foregroundColor: const Color.fromARGB(255, 251, 251, 251),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            child: const Text(
                              'Log In',
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // =========================
              // REGISTER / FORGOT PASSWORD
              // =========================
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  GestureDetector(
                    onTap: () {
                      // Register
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xff2271b1),
                      ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '|',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xff8c8f94),
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                    },
                    child: const Text(
                      'Lost your password?',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xff2271b1),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}