// Application State
const app = {
    state: {
        transactions: [],
        categories: {
            income: [
                { id: 'salary', name: 'Salary', icon: '💼', color: '#10b981' },
                { id: 'freelance', name: 'Freelance', icon: '💻', color: '#3b82f6' },
                { id: 'investment', name: 'Investment', icon: '📈', color: '#8b5cf6' },
                { id: 'gift', name: 'Gift', icon: '🎁', color: '#ec4899' },
                { id: 'other-income', name: 'Other', icon: '💰', color: '#6366f1' }
            ],
            expense: [
                { id: 'food', name: 'Food', icon: '🍔', color: '#ef4444' },
                { id: 'transport', name: 'Transport', icon: '🚗', color: '#f59e0b' },
                { id: 'shopping', name: 'Shopping', icon: '🛍️', color: '#ec4899' },
                { id: 'bills', name: 'Bills', icon: '📄', color: '#6366f1' },
                { id: 'entertainment', name: 'Entertainment', icon: '🎮', color: '#8b5cf6' },
                { id: 'health', name: 'Health', icon: '🏥', color: '#10b981' },
                { id: 'education', name: 'Education', icon: '📚', color: '#3b82f6' },
                { id: 'other-expense', name: 'Other', icon: '💸', color: '#64748b' }
            ]
        },
        budgets: [],
        recurringTransactions: [],
        settings: {
            currency: 'USD',
            theme: 'light',
            language: 'en',
            exchangeRates: {} // Custom exchange rates
        },
        filters: {
            type: 'all',
            category: 'all',
            sort: 'newest',
            search: ''
        },
        editingTransaction: null
    },

    // Initialize app
    init() {
        this.loadState();
        this.setupEventListeners();
        this.updateAllUI();
        this.processRecurringTransactions();
        this.renderCharts();
    },

    // Load state from localStorage
    loadState() {
        const saved = localStorage.getItem('expenseTrackerData');
        if (saved) {
            try {
                const data = JSON.parse(saved);
                this.state = { ...this.state, ...data };
            } catch (e) {
                console.error('Failed to load state:', e);
            }
        }

        // Apply saved settings
        if (this.state.settings.theme === 'dark') {
            document.documentElement.setAttribute('data-theme', 'dark');
            document.getElementById('themeToggle').querySelector('.theme-icon').textContent = '☀️';
        }

        if (this.state.settings.language) {
            i18n.setLanguage(this.state.settings.language);
            document.getElementById('languageSelect').value = this.state.settings.language;
        }

        if (this.state.settings.currency) {
            document.getElementById('currencySelect').value = this.state.settings.currency;
        }
    },

    // Save state to localStorage
    saveState() {
        try {
            localStorage.setItem('expenseTrackerData', JSON.stringify(this.state));
        } catch (e) {
            console.error('Failed to save state:', e);
        }
    },

    // Setup event listeners
    setupEventListeners() {
        // Navigation
        document.querySelectorAll('.nav-btn').forEach(btn => {
            btn.addEventListener('click', () => this.navigateTo(btn.dataset.page));
        });

        // Theme toggle
        document.getElementById('themeToggle').addEventListener('click', () => this.toggleTheme());

        // FAB
        document.getElementById('addTransactionFab').addEventListener('click', () => this.openTransactionModal());

        // Transaction modal
        document.getElementById('closeTransactionModal').addEventListener('click', () => this.closeTransactionModal());
        document.getElementById('cancelTransactionBtn').addEventListener('click', () => this.closeTransactionModal());
        document.getElementById('transactionForm').addEventListener('submit', (e) => this.handleTransactionSubmit(e));

        // Type toggle
        document.querySelectorAll('.type-btn').forEach(btn => {
            btn.addEventListener('click', () => this.setTransactionType(btn.dataset.type));
        });

        // Recurring checkbox
        document.getElementById('transactionRecurring').addEventListener('change', (e) => {
            document.getElementById('recurringOptions').style.display = e.target.checked ? 'block' : 'none';
        });

        // Filters
        document.getElementById('searchInput').addEventListener('input', (e) => {
            this.state.filters.search = e.target.value;
            this.renderTransactions();
        });

        document.getElementById('typeFilter').addEventListener('change', (e) => {
            this.state.filters.type = e.target.value;
            this.renderTransactions();
        });

        document.getElementById('categoryFilter').addEventListener('change', (e) => {
            this.state.filters.category = e.target.value;
            this.renderTransactions();
        });

        document.getElementById('sortFilter').addEventListener('change', (e) => {
            this.state.filters.sort = e.target.value;
            this.renderTransactions();
        });

        // Budget modal
        document.getElementById('addBudgetBtn').addEventListener('click', () => this.openBudgetModal());
        document.getElementById('closeBudgetModal').addEventListener('click', () => this.closeBudgetModal());
        document.getElementById('cancelBudgetBtn').addEventListener('click', () => this.closeBudgetModal());
        document.getElementById('budgetForm').addEventListener('submit', (e) => this.handleBudgetSubmit(e));

        // Settings
        document.getElementById('languageSelect').addEventListener('change', (e) => {
            this.state.settings.language = e.target.value;
            i18n.setLanguage(e.target.value);
            this.saveState();
            this.updateAllUI();
        });

        document.getElementById('currencySelect').addEventListener('change', (e) => {
            this.state.settings.currency = e.target.value;
            this.saveState();
            this.updateAllUI();
        });

        // Export
        document.getElementById('exportCSVBtn').addEventListener('click', () => this.exportCSV());
        document.getElementById('exportJSONBtn').addEventListener('click', () => this.exportJSON());

        // Close modal on backdrop click
        document.querySelectorAll('.modal').forEach(modal => {
            modal.addEventListener('click', (e) => {
                if (e.target === modal) {
                    modal.classList.remove('active');
                }
            });
        });
    },

    // Navigation
    navigateTo(page) {
        document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
        document.querySelectorAll('.nav-btn').forEach(b => b.classList.remove('active'));

        document.getElementById(`${page}-page`).classList.add('active');
        document.querySelector(`[data-page="${page}"]`).classList.add('active');

        if (page === 'dashboard') {
            this.renderCharts();
        } else if (page === 'transactions') {
            this.renderTransactions();
        } else if (page === 'budgets') {
            this.renderBudgets();
        }
    },

    // Theme
    toggleTheme() {
        const currentTheme = document.documentElement.getAttribute('data-theme');
        const newTheme = currentTheme === 'dark' ? 'light' : 'dark';

        document.documentElement.setAttribute('data-theme', newTheme);
        this.state.settings.theme = newTheme;

        const icon = document.getElementById('themeToggle').querySelector('.theme-icon');
        icon.textContent = newTheme === 'dark' ? '☀️' : '🌙';

        this.saveState();
    },

    // Transaction Modal
    openTransactionModal(transaction = null) {
        const modal = document.getElementById('transactionModal');
        const form = document.getElementById('transactionForm');

        form.reset();
        this.state.editingTransaction = transaction;

        if (transaction) {
            document.getElementById('modalTitle').textContent = i18n.t('edit');
            document.getElementById('transactionAmount').value = transaction.amount;
            document.getElementById('transactionCategory').value = transaction.categoryId;
            document.getElementById('transactionDate').value = transaction.date;
            document.getElementById('transactionDescription').value = transaction.description || '';
            document.getElementById('transactionPayment').value = transaction.paymentMethod || 'cash';

            // Set type
            this.setTransactionType(transaction.type);
        } else {
            document.getElementById('modalTitle').textContent = i18n.t('addTransaction');
            document.getElementById('transactionDate').value = new Date().toISOString().split('T')[0];
            this.setTransactionType('expense');
        }

        modal.classList.add('active');
    },

    closeTransactionModal() {
        document.getElementById('transactionModal').classList.remove('active');
        this.state.editingTransaction = null;
    },

    setTransactionType(type) {
        document.querySelectorAll('.type-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.type === type);
        });

        // Update category dropdown
        this.updateCategoryDropdown(type);
    },

    updateCategoryDropdown(type) {
        const select = document.getElementById('transactionCategory');
        const categories = this.state.categories[type];

        select.innerHTML = '<option value="">Select category</option>';
        categories.forEach(cat => {
            const option = document.createElement('option');
            option.value = cat.id;
            option.textContent = `${cat.icon} ${i18n.t(cat.id) || cat.name}`;
            select.appendChild(option);
        });
    },

    handleTransactionSubmit(e) {
        e.preventDefault();

        const type = document.querySelector('.type-btn.active').dataset.type;
        const amount = parseFloat(document.getElementById('transactionAmount').value);
        const categoryId = document.getElementById('transactionCategory').value;
        const date = document.getElementById('transactionDate').value;
        const description = document.getElementById('transactionDescription').value;
        const paymentMethod = document.getElementById('transactionPayment').value;
        const isRecurring = document.getElementById('transactionRecurring').checked;
        const frequency = document.getElementById('transactionFrequency').value;

        const category = this.state.categories[type].find(c => c.id === categoryId);

        const transaction = {
            id: this.state.editingTransaction?.id || Date.now().toString(),
            type,
            amount,
            categoryId,
            category: category.name,
            icon: category.icon,
            color: category.color,
            date,
            description,
            paymentMethod,
            timestamp: this.state.editingTransaction?.timestamp || Date.now()
        };

        if (this.state.editingTransaction) {
            // Update existing
            const index = this.state.transactions.findIndex(t => t.id === this.state.editingTransaction.id);
            this.state.transactions[index] = transaction;
            this.showToast(i18n.t('transactionUpdated'));
        } else {
            // Add new
            this.state.transactions.push(transaction);
            this.showToast(i18n.t('transactionAdded'));

            // Handle recurring
            if (isRecurring) {
                this.state.recurringTransactions.push({
                    ...transaction,
                    frequency,
                    lastGenerated: date
                });
            }
        }

        this.saveState();
        this.updateAllUI();
        this.closeTransactionModal();
    },

    deleteTransaction(id) {
        if (confirm('Delete this transaction?')) {
            this.state.transactions = this.state.transactions.filter(t => t.id !== id);
            this.saveState();
            this.updateAllUI();
            this.showToast(i18n.t('transactionDeleted'));
        }
    },

    // Recurring Transactions
    processRecurringTransactions() {
        const today = new Date().toISOString().split('T')[0];

        this.state.recurringTransactions.forEach(recurring => {
            const lastDate = new Date(recurring.lastGenerated);
            const todayDate = new Date(today);

            let shouldGenerate = false;

            switch (recurring.frequency) {
                case 'daily':
                    shouldGenerate = (todayDate - lastDate) >= 86400000;
                    break;
                case 'weekly':
                    shouldGenerate = (todayDate - lastDate) >= 604800000;
                    break;
                case 'monthly':
                    shouldGenerate = todayDate.getMonth() !== lastDate.getMonth() ||
                        todayDate.getFullYear() !== lastDate.getFullYear();
                    break;
                case 'yearly':
                    shouldGenerate = todayDate.getFullYear() !== lastDate.getFullYear();
                    break;
            }

            if (shouldGenerate) {
                const newTransaction = {
                    ...recurring,
                    id: Date.now().toString() + Math.random(),
                    date: today,
                    timestamp: Date.now()
                };
                delete newTransaction.frequency;
                delete newTransaction.lastGenerated;

                this.state.transactions.push(newTransaction);
                recurring.lastGenerated = today;
            }
        });

        this.saveState();
    },

    // Budget Modal
    openBudgetModal() {
        document.getElementById('budgetModal').classList.add('active');
        this.updateBudgetCategoryDropdown();
    },

    closeBudgetModal() {
        document.getElementById('budgetModal').classList.remove('active');
    },

    updateBudgetCategoryDropdown() {
        const select = document.getElementById('budgetCategory');
        const categories = this.state.categories.expense;

        select.innerHTML = '<option value="">Select category</option>';
        categories.forEach(cat => {
            const option = document.createElement('option');
            option.value = cat.id;
            option.textContent = `${cat.icon} ${i18n.t(cat.id) || cat.name}`;
            select.appendChild(option);
        });
    },

    handleBudgetSubmit(e) {
        e.preventDefault();

        const categoryId = document.getElementById('budgetCategory').value;
        const amount = parseFloat(document.getElementById('budgetAmount').value);
        const category = this.state.categories.expense.find(c => c.id === categoryId);

        const budget = {
            id: Date.now().toString(),
            categoryId,
            category: category.name,
            icon: category.icon,
            amount
        };

        // Remove existing budget for this category
        this.state.budgets = this.state.budgets.filter(b => b.categoryId !== categoryId);
        this.state.budgets.push(budget);

        this.saveState();
        this.renderBudgets();
        this.closeBudgetModal();
        this.showToast('Budget set successfully');
    },

    // Render Functions
    updateAllUI() {
        this.updateSummary();
        this.renderTransactions();
        this.renderBudgets();
        this.renderCharts();
        this.updateCategoryFilter();
    },

    updateSummary() {
        const currentMonth = new Date().toISOString().slice(0, 7);
        const monthTransactions = this.state.transactions.filter(t => t.date.startsWith(currentMonth));

        const totalIncome = monthTransactions
            .filter(t => t.type === 'income')
            .reduce((sum, t) => sum + t.amount, 0);

        const totalExpenses = monthTransactions
            .filter(t => t.type === 'expense')
            .reduce((sum, t => sum + t.amount, 0);

        const netBalance = totalIncome - totalExpenses;

        document.getElementById('totalIncome').textContent = this.formatCurrency(totalIncome);
        document.getElementById('totalExpenses').textContent = this.formatCurrency(totalExpenses);
        document.getElementById('netBalance').textContent = this.formatCurrency(netBalance);
    },

    renderTransactions() {
        const container = document.getElementById('transactionsList');
        let transactions = [...this.state.transactions];

        // Apply filters
        if (this.state.filters.type !== 'all') {
            transactions = transactions.filter(t => t.type === this.state.filters.type);
        }

        if (this.state.filters.category !== 'all') {
            transactions = transactions.filter(t => t.categoryId === this.state.filters.category);
        }

        if (this.state.filters.search) {
            const search = this.state.filters.search.toLowerCase();
            transactions = transactions.filter(t =>
                t.category.toLowerCase().includes(search) ||
                (t.description && t.description.toLowerCase().includes(search))
            );
        }

        // Apply sorting
        transactions.sort((a, b) => {
            switch (this.state.filters.sort) {
                case 'newest':
                    return b.timestamp - a.timestamp;
                case 'oldest':
                    return a.timestamp - b.timestamp;
                case 'highest':
                    return b.amount - a.amount;
                case 'lowest':
                    return a.amount - b.amount;
                default:
                    return 0;
            }
        });

        if (transactions.length === 0) {
            container.innerHTML = `
        <div class="empty-state">
          <div class="empty-icon">📝</div>
          <p data-i18n="noTransactions">${i18n.t('noTransactions')}</p>
        </div>
      `;
            return;
        }

        container.innerHTML = transactions.map(t => `
      <div class="transaction-item ${t.type}">
        <div class="transaction-icon">${t.icon}</div>
        <div class="transaction-details">
          <div class="transaction-category">${i18n.t(t.categoryId) || t.category}</div>
          <div class="transaction-description">${t.description || i18n.t(t.paymentMethod || 'cash')}</div>
        </div>
        <div class="transaction-meta">
          <div class="transaction-amount">${t.type === 'income' ? '+' : '-'}${this.formatCurrency(t.amount)}</div>
          <div class="transaction-date">${i18n.formatDate(t.date)}</div>
        </div>
        <div class="transaction-actions">
          <button onclick="app.openTransactionModal(app.state.transactions.find(tr => tr.id === '${t.id}'))" title="Edit">✏️</button>
          <button onclick="app.deleteTransaction('${t.id}')" title="Delete">🗑️</button>
        </div>
      </div>
    `).join('');
    },

    renderBudgets() {
        const container = document.getElementById('budgetsList');
        const currentMonth = new Date().toISOString().slice(0, 7);

        if (this.state.budgets.length === 0) {
            container.innerHTML = `
        <div class="empty-state">
          <div class="empty-icon">💰</div>
          <p>No budgets set</p>
        </div>
      `;
            return;
        }

        container.innerHTML = this.state.budgets.map(budget => {
            const spent = this.state.transactions
                .filter(t => t.type === 'expense' && t.categoryId === budget.categoryId && t.date.startsWith(currentMonth))
                .reduce((sum, t) => sum + t.amount, 0);

            const percentage = Math.min((spent / budget.amount) * 100, 100);
            const remaining = Math.max(budget.amount - spent, 0);

            let fillClass = '';
            if (percentage >= 100) fillClass = 'danger';
            else if (percentage >= 90) fillClass = 'warning';

            return `
        <div class="budget-item">
          <div class="budget-header">
            <div class="budget-category">${budget.icon} ${i18n.t(budget.categoryId) || budget.category}</div>
            <div class="budget-amount">${this.formatCurrency(budget.amount)}</div>
          </div>
          <div class="budget-progress">
            <div class="budget-bar">
              <div class="budget-fill ${fillClass}" style="width: ${percentage}%"></div>
            </div>
          </div>
          <div class="budget-stats">
            <span>${i18n.t('spent')}: ${this.formatCurrency(spent)}</span>
            <span>${i18n.t('remaining')}: ${this.formatCurrency(remaining)}</span>
          </div>
        </div>
      `;
        }).join('');
    },

    updateCategoryFilter() {
        const select = document.getElementById('categoryFilter');
        const allCategories = [...this.state.categories.income, ...this.state.categories.expense];

        const current = select.value;
        select.innerHTML = `<option value="all">${i18n.t('all')}</option>`;

        allCategories.forEach(cat => {
            const option = document.createElement('option');
            option.value = cat.id;
            option.textContent = `${cat.icon} ${i18n.t(cat.id) || cat.name}`;
            select.appendChild(option);
        });

        select.value = current;
    },

    // Utility Functions
    formatCurrency(amount) {
        return i18n.formatCurrency(amount, this.state.settings.currency);
    },

    showToast(message) {
        const toast = document.getElementById('toast');
        toast.textContent = message;
        toast.classList.add('active');

        setTimeout(() => {
            toast.classList.remove('active');
        }, 3000);
    },

    // Export Functions
    exportCSV() {
        const headers = ['Date', 'Type', 'Category', 'Amount', 'Description', 'Payment Method'];
        const rows = this.state.transactions.map(t => [
            t.date,
            t.type,
            t.category,
            t.amount,
            t.description || '',
            t.paymentMethod || ''
        ]);

        const csv = [headers, ...rows].map(row => row.join(',')).join('\n');
        this.downloadFile(csv, `expense_tracker_${new Date().toISOString().split('T')[0]}.csv`, 'text/csv');
        this.showToast('Exported to CSV');
    },

    exportJSON() {
        const data = JSON.stringify(this.state, null, 2);
        this.downloadFile(data, `expense_tracker_${new Date().toISOString().split('T')[0]}.json`, 'application/json');
        this.showToast('Exported to JSON');
    },

    downloadFile(content, filename, type) {
        const blob = new Blob([content], { type });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = filename;
        a.click();
        URL.revokeObjectURL(url);
    },

    // Charts (will be implemented in charts.js)
    renderCharts() {
        if (window.renderCharts) {
            window.renderCharts(this.state, i18n);
        }
    }
};

// Initialize app when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => app.init());
} else {
    app.init();
}
