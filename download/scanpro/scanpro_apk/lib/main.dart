import 'package:flutter/material.dart';

void main() {
  runApp(const ScanProApp());
}

class ScanProApp extends StatelessWidget {
  const ScanProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScanPro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF4D2DAB),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF4D2DAB),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _tab = 0;

  final List<Widget> _screens = const [
    HomeTab(),
    DocsTab(),
    ScanTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Docs',
          ),
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('ScanPro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Welcome back!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _QuickAction(icon: Icons.document_scanner, label: 'Scan', color: const Color(0xFF4D2DAB)),
              _QuickAction(icon: Icons.photo_library, label: 'Import', color: const Color(0xFF2D7DAB)),
              _QuickAction(icon: Icons.qr_code_scanner, label: 'QR Code', color: const Color(0xFF2DAB6F)),
              _QuickAction(icon: Icons.picture_as_pdf, label: 'PDF Tools', color: const Color(0xFFAB2D6F)),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Recent Documents',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...['Invoice_2024.pdf', 'Receipt_Amazon.pdf', 'Contract_Draft.pdf', 'ID_Card_Scan.jpg'].map(
            (name) => Card(
              child: ListTile(
                leading: Icon(
                  name.endsWith('.pdf') ? Icons.picture_as_pdf : Icons.image,
                  color: theme.colorScheme.primary,
                ),
                title: Text(name),
                subtitle: const Text('2 days ago'),
                trailing: const Icon(Icons.more_vert),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Storage', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 0.35,
                      minHeight: 8,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('1.2 GB of 5 GB used', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickAction({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class DocsTab extends StatelessWidget {
  const DocsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Documents')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
        ),
        itemCount: 6,
        itemBuilder: (context, i) => Card(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Center(child: Icon(Icons.description, size: 48)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text('Document ${i + 1}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScanTab extends StatelessWidget {
  const ScanTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.document_scanner, size: 100, color: theme.colorScheme.primary.withOpacity(0.3)),
            const SizedBox(height: 20),
            Text('Tap to Scan', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 40),
            FloatingActionButton.large(
              onPressed: () {},
              child: const Icon(Icons.camera_alt, size: 32),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: theme.colorScheme.primary,
                  child: const Icon(Icons.person, size: 44, color: Colors.white),
                ),
                const SizedBox(height: 12),
                const Text('ScanPro User', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...[
            (Icons.cloud_outlined, 'Cloud Sync', 'Backup & restore'),
            (Icons.security, 'Security', 'PIN lock & biometric'),
            (Icons.smart_toy, 'AI Features', 'Summary & extraction'),
            (Icons.picture_as_pdf, 'PDF Tools', 'Merge, split & compress'),
            (Icons.text_fields, 'OCR', 'Text recognition'),
            (Icons.settings, 'Settings', 'App preferences'),
            (Icons.info_outline, 'About', 'ScanPro v1.0.0'),
          ].map((item) => Card(
            child: ListTile(
              leading: Icon(item.$1, color: const Color(0xFF4D2DAB)),
              title: Text(item.$2),
              subtitle: Text(item.$3, style: const TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right),
            ),
          )),
        ],
      ),
    );
  }
}
