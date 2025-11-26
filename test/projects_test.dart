import 'package:flutter_test/flutter_test.dart';
import 'package:calc/models/project.dart';
import 'package:calc/models/transaction.dart';
import 'package:calc/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Project Tests', () {
    late StorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = StorageService();
    });

    test('Create and Retrieve Project', () async {
      final project = Project(
        id: 'p1',
        name: 'Test Project',
        icon: '📁',
        colorValue: 0xFF000000,
        createdDate: DateTime.now(),
      );

      await storage.addProject(project);
      final projects = await storage.getProjects();

      expect(projects.length, 1);
      expect(projects.first.id, 'p1');
      expect(projects.first.name, 'Test Project');
    });

    test('Update Project', () async {
      final project = Project(
        id: 'p1',
        name: 'Test Project',
        icon: '📁',
        colorValue: 0xFF000000,
        createdDate: DateTime.now(),
      );

      await storage.addProject(project);

      final updatedProject = project.copyWith(name: 'Updated Project');
      await storage.updateProject(updatedProject);

      final projects = await storage.getProjects();
      expect(projects.first.name, 'Updated Project');
    });

    test('Delete Project', () async {
      final project = Project(
        id: 'p1',
        name: 'Test Project',
        icon: '📁',
        colorValue: 0xFF000000,
        createdDate: DateTime.now(),
      );

      await storage.addProject(project);
      await storage.deleteProject('p1');

      final projects = await storage.getProjects();
      expect(projects.isEmpty, true);
    });

    test('Transaction Assignment', () async {
      final project = Project(
        id: 'p1',
        name: 'Test Project',
        icon: '📁',
        colorValue: 0xFF000000,
        createdDate: DateTime.now(),
      );
      await storage.addProject(project);

      final transaction = Transaction(
        id: 't1',
        amount: 100.0,
        type: 'expense',
        categoryId: 'food',
        category: 'Food',
        icon: '🍔',
        date: DateTime.now(),
        projectId: 'p1',
      );
      await storage.addTransaction(transaction);

      final projectTransactions = await storage.getProjectTransactions('p1');
      expect(projectTransactions.length, 1);
      expect(projectTransactions.first.id, 't1');
      expect(projectTransactions.first.projectId, 'p1');
    });

    test('Project Stats Calculation', () async {
      final project = Project(
        id: 'p1',
        name: 'Test Project',
        icon: '📁',
        colorValue: 0xFF000000,
        createdDate: DateTime.now(),
        budget: 500.0,
      );
      await storage.addProject(project);

      final income = Transaction(
        id: 't1',
        amount: 200.0,
        type: 'income',
        categoryId: 'salary',
        category: 'Salary',
        icon: '💰',
        date: DateTime.now(),
        projectId: 'p1',
      );
      final expense = Transaction(
        id: 't2',
        amount: 50.0,
        type: 'expense',
        categoryId: 'food',
        category: 'Food',
        icon: '🍔',
        date: DateTime.now(),
        projectId: 'p1',
      );

      await storage.addTransaction(income);
      await storage.addTransaction(expense);

      final stats = await storage.getProjectStats('p1');
      expect(stats['income'], 200.0);
      expect(stats['expenses'], 50.0);
      expect(stats['balance'], 150.0);
      expect(stats['count'], 2.0);
    });
  });
}
