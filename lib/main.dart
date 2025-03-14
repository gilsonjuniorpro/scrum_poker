import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scrum Poker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate a small delay for login
      Future.delayed(const Duration(seconds: 1), () {
        final username = _usernameController.text;
        final password = _passwordController.text;

        if (password == '12345') {
          if (username == 'eivan') {
            // Admin login
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const ScrumPokerPage(isAdmin: true),
              ),
            );
          } else if (username == 'usuario') {
            // User login
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder:
                    (context) =>
                        ScrumPokerPage(isAdmin: false, currentUser: username),
              ),
            );
          } else {
            _showError();
          }
        } else {
          _showError();
        }
      });
    }
  }

  void _showError() {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invalid username or password'),
        backgroundColor: Colors.red,
      ),
    );
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.security, size: 80, color: Colors.blue),
                    const SizedBox(height: 32),
                    const Text(
                      'Scrum Poker Login',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('Login'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ScrumPokerPage extends StatefulWidget {
  final bool isAdmin;
  final String? currentUser;

  const ScrumPokerPage({super.key, required this.isAdmin, this.currentUser});

  @override
  State<ScrumPokerPage> createState() => _ScrumPokerPageState();
}

class _ScrumPokerPageState extends State<ScrumPokerPage> {
  final List<int> cardValues = [1, 2, 3, 5, 8];
  List<UserVote> userVotes = [
    UserVote(name: 'John', selectedValue: 0),
    UserVote(name: 'Alice', selectedValue: 0),
    UserVote(name: 'Bob', selectedValue: 0),
  ];
  List<UserVote> availableUsers = [
    UserVote(name: 'Sarah', selectedValue: 0),
    UserVote(name: 'Mike', selectedValue: 0),
    UserVote(name: 'Emma', selectedValue: 0),
    UserVote(name: 'David', selectedValue: 0),
    UserVote(name: 'Lisa', selectedValue: 0),
  ];
  bool _areEstimatesRevealed = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isAdmin && widget.currentUser != null) {
      // Add current user to the votes list if not already present
      if (!userVotes.any((vote) => vote.name == widget.currentUser)) {
        userVotes.add(UserVote(name: widget.currentUser!, selectedValue: 0));
      }
    }
    // Remove users that are already in the current list
    availableUsers.removeWhere(
      (user) => userVotes.any((current) => current.name == user.name),
    );
  }

  void _handleCardSelection(int value) {
    if (!widget.isAdmin && widget.currentUser != null) {
      setState(() {
        final userIndex = userVotes.indexWhere(
          (vote) => vote.name == widget.currentUser,
        );
        if (userIndex != -1) {
          // Update existing user's vote
          userVotes[userIndex] = UserVote(
            name: widget.currentUser!,
            selectedValue: value,
          );
        } else {
          // Add new user vote
          userVotes.add(
            UserVote(name: widget.currentUser!, selectedValue: value),
          );
        }
      });
    }
  }

  void _removeUser(UserVote user) {
    setState(() {
      userVotes.removeWhere((vote) => vote.name == user.name);
      if (!availableUsers.any((u) => u.name == user.name)) {
        availableUsers.add(UserVote(name: user.name, selectedValue: 0));
      }
    });
  }

  void _addUser(UserVote user) {
    setState(() {
      userVotes.add(user);
      availableUsers.removeWhere((u) => u.name == user.name);
    });
  }

  Future<void> _launchTicketUrl() async {
    final Uri url = Uri.parse('https://www.google.com');
    try {
      if (!await launchUrl(
        url,
        mode: LaunchMode.platformDefault,
        webOnlyWindowName: '_blank',
      )) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open the ticket'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the ticket'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading:
            widget.isAdmin
                ? IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => UserManagementScreen(
                              currentUsers: userVotes,
                              availableUsers: availableUsers,
                              onAddUser: _addUser,
                            ),
                      ),
                    );
                  },
                )
                : null,
        title: Text(
          widget.isAdmin ? 'Scrum Poker (Admin)' : 'Scrum Poker',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: _launchTicketUrl,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.link, size: 16, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'CDL-19834',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final spacing = 8.0;
                      final screenWidth = MediaQuery.of(context).size.width;
                      final isMobile = screenWidth < 600;

                      if (isMobile) {
                        // For mobile: calculate card width based on screen width
                        final totalSpacing = (cardValues.length + 1) * spacing;
                        final availableWidth =
                            constraints.maxWidth - totalSpacing;
                        final cardWidth = availableWidth / cardValues.length;
                        final cardHeight = cardWidth * 1.4; // Maintain ratio

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            cardValues.length,
                            (index) => InkWell(
                              onTap: () {
                                _handleCardSelection(cardValues[index]);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Selected card: ${cardValues[index]}',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 4,
                                child: Container(
                                  width: cardWidth,
                                  height: cardHeight,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.blue,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          '${cardValues[index]}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        // Desktop/Web version with horizontal scroll
                        final maxHeight = constraints.maxHeight;
                        final cardHeight = maxHeight * 0.9;
                        final cardWidth = cardHeight / 1.4;

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              cardValues.length,
                              (index) => Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: spacing / 2,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    _handleCardSelection(cardValues[index]);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Selected card: ${cardValues[index]}',
                                        ),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    elevation: 4,
                                    child: Container(
                                      width: cardWidth,
                                      height: cardHeight,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.blue,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              '${cardValues[index]}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (widget.isAdmin) ...[
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _areEstimatesRevealed = !_areEstimatesRevealed;
                      });
                    },
                    icon: Icon(
                      _areEstimatesRevealed
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white,
                    ),
                    label: Text(
                      _areEstimatesRevealed
                          ? 'Hide Estimates'
                          : 'Reveal Estimates',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
              const Text(
                'User Votes:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userVotes.length,
                itemBuilder: (context, index) {
                  final vote = userVotes[index];
                  final bool showValue =
                      widget.isAdmin
                          ? _areEstimatesRevealed
                          : vote.name == widget.currentUser;
                  final bool hasVoted = vote.selectedValue > 0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  hasVoted ? Colors.blue : Colors.red,
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(vote.name),
                            trailing: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 40,
                              height: 40,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: hasVoted ? Colors.blue : Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child:
                                  showValue
                                      ? Text(
                                        '${vote.selectedValue}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      )
                                      : const Icon(
                                        Icons.question_mark,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                            ),
                          ),
                        ),
                        if (widget.isAdmin)
                          Positioned(
                            top: -8,
                            right: -8,
                            child: Material(
                              type: MaterialType.transparency,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _removeUser(vote),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class UserVote {
  final String name;
  final int selectedValue;

  UserVote({required this.name, required this.selectedValue});
}

class UserManagementScreen extends StatefulWidget {
  final List<UserVote> currentUsers;
  final List<UserVote> availableUsers;
  final Function(UserVote) onAddUser;

  const UserManagementScreen({
    super.key,
    required this.currentUsers,
    required this.availableUsers,
    required this.onAddUser,
  });

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<UserVote> _localAvailableUsers = [];
  final TextEditingController _newUserController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _localAvailableUsers = List.from(widget.availableUsers);
  }

  @override
  void dispose() {
    _newUserController.dispose();
    super.dispose();
  }

  void _handleAddUser(UserVote user) {
    widget.onAddUser(user);
    setState(() {
      _localAvailableUsers.removeWhere((u) => u.name == user.name);
    });
  }

  void _addNewUser() {
    final name = _newUserController.text.trim();
    if (name.isNotEmpty) {
      // Case-insensitive check for duplicates
      final nameLower = name.toLowerCase();
      if (widget.currentUsers.any(
            (user) => user.name.toLowerCase() == nameLower,
          ) ||
          _localAvailableUsers.any(
            (user) => user.name.toLowerCase() == nameLower,
          )) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User "$name" already exists in the system'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      } else {
        setState(() {
          _localAvailableUsers.add(UserVote(name: name, selectedValue: 0));
          _newUserController.clear();
        });
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User "$name" added successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a user name'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'User Management',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newUserController,
                    decoration: const InputDecoration(
                      labelText: 'New User Name',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _addNewUser(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _addNewUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Add User'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Available Users',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _localAvailableUsers.length,
                itemBuilder: (context, index) {
                  final user = _localAvailableUsers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(user.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle),
                        color: Colors.blue,
                        onPressed: () => _handleAddUser(user),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
