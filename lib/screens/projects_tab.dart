import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/storage_service.dart';
import '../services/app_localizations.dart';
import 'add_project_screen.dart';
import 'project_details_screen.dart';

class ProjectsTab extends StatefulWidget {
  const ProjectsTab({super.key});

  @override
  State<ProjectsTab> createState() => _ProjectsTabState();
}

class _ProjectsTabState extends State<ProjectsTab> {
  final StorageService _storage = StorageService();
  List<Project> _projects = [];
  Map<String, Map<String, double>> _projectStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);

    final projects = await _storage.getProjects();
    final stats = <String, Map<String, double>>{};

    for (final project in projects) {
      stats[project.id] = await _storage.getProjectStats(project.id);
    }

    setState(() {
      _projects = projects.where((p) => p.isActive).toList();
      _projectStats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.translate('projects'))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
          ? _buildEmptyState()
          : _buildProjectsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProjectScreen()),
          );
          if (result != null && mounted) {
            _loadProjects();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).translate('noProjectsYet'),
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProjectScreen()),
              );
              if (result != null && mounted) _loadProjects();
            },
            icon: const Icon(Icons.add),
            label: Text(
              AppLocalizations.of(context).translate('createProject'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList() {
    return RefreshIndicator(
      onRefresh: _loadProjects,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _projects.length,
        itemBuilder: (context, index) {
          final project = _projects[index];
          final stats = _projectStats[project.id] ?? {};
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: Text(project.icon, style: const TextStyle(fontSize: 32)),
              title: Text(project.name),
              subtitle: Text('\$${(stats['balance'] ?? 0).toStringAsFixed(2)}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProjectDetailsScreen(project: project),
                  ),
                );
                // Always reload to get fresh stats
                if (mounted) _loadProjects();
              },
            ),
          );
        },
      ),
    );
  }
}
