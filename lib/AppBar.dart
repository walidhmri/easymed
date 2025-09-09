import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_malade/user_provider.dart';
import 'user_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;

  CustomAppBar({super.key, this.showBackButton = true});

  final String defaultAvatarUrl =
      "https://firebasestorage.googleapis.com/v0/b/easy-med-c3f69.firebasestorage.app/o/profile_images%2Favatar-simple.jpg?alt=media&token=cbf516b6-ad37-4c50-852d-58f0b83564d5";

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/pink_header_3.png'),
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Bonjour ${userProvider.name}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipOval(
              child: Image.network(
                userProvider.profileImage.startsWith('http')
                    ? userProvider.profileImage
                    : defaultAvatarUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
