// Internationalization (i18n) Module
const i18n = {
  currentLanguage: localStorage.getItem('language') || 'en',
  
  translations: {
    en: {
      // App Title
      appTitle: 'Expense Tracker',
      
      // Navigation
      dashboard: 'Dashboard',
      transactions: 'Transactions',
      budgets: 'Budgets',
      settings: 'Settings',
      
      // Dashboard
      totalIncome: 'Total Income',
      totalExpenses: 'Total Expenses',
      netBalance: 'Net Balance',
      thisMonth: 'This Month',
      
      // Transactions
      addTransaction: 'Add Transaction',
      income: 'Income',
      expense: 'Expense',
      amount: 'Amount',
      category: 'Category',
      date: 'Date',
      description: 'Description',
      paymentMethod: 'Payment Method',
      type: 'Type',
      
      // Categories
      categories: 'Categories',
      incomeCategories: 'Income Categories',
      expenseCategories: 'Expense Categories',
      addCategory: 'Add Category',
      categoryName: 'Category Name',
      categoryColor: 'Category Color',
      
      // Predefined Categories - Expense
      food: 'Food',
      transport: 'Transport',
      shopping: 'Shopping',
      bills: 'Bills',
      entertainment: 'Entertainment',
      health: 'Health',
      education: 'Education',
      other: 'Other',
      
      // Predefined Categories - Income
      salary: 'Salary',
      freelance: 'Freelance',
      investment: 'Investment',
      gift: 'Gift',
      
      // Payment Methods
      cash: 'Cash',
      card: 'Card',
      bankTransfer: 'Bank Transfer',
      digitalWallet: 'Digital Wallet',
      
      // Filters
      filter: 'Filter',
      filterBy: 'Filter By',
      sortBy: 'Sort By',
      search: 'Search',
      clearFilters: 'Clear Filters',
      all: 'All',
      
      // Sort Options
      newest: 'Newest First',
      oldest: 'Oldest First',
      highestAmount: 'Highest Amount',
      lowestAmount: 'Lowest Amount',
      
      // Budgets
      setBudget: 'Set Budget',
      monthlyBudget: 'Monthly Budget',
      budgetLimit: 'Budget Limit',
      spent: 'Spent',
      remaining: 'Remaining',
      
      // Recurring
      recurring: 'Recurring',
      frequency: 'Frequency',
      daily: 'Daily',
      weekly: 'Weekly',
      monthly: 'Monthly',
      yearly: 'Yearly',
      
      // Currency
      currency: 'Currency',
      baseCurrency: 'Base Currency',
      exchangeRate: 'Exchange Rate',
      customRates: 'Custom Rates',
      
      // Export
      export: 'Export',
      exportCSV: 'Export CSV',
      exportJSON: 'Export JSON',
      
      // Settings
      language: 'Language',
      theme: 'Theme',
      darkMode: 'Dark Mode',
      lightMode: 'Light Mode',
      
      // Actions
      save: 'Save',
      cancel: 'Cancel',
      delete: 'Delete',
      edit: 'Edit',
      add: 'Add',
      close: 'Close',
      confirm: 'Confirm',
      
      // Messages
      transactionAdded: 'Transaction added successfully',
      transactionUpdated: 'Transaction updated successfully',
      transactionDeleted: 'Transaction deleted successfully',
      budgetExceeded: 'Budget exceeded!',
      budgetWarning: 'You are approaching your budget limit',
      noTransactions: 'No transactions yet',
      
      // Charts
      incomeVsExpense: 'Income vs Expense',
      expenseBreakdown: 'Expense Breakdown',
      incomeBreakdown: 'Income Breakdown',
      monthlyTrend: 'Monthly Trend',
      balanceTrend: 'Balance Trend',
    },
    
    fr: {
      // App Title
      appTitle: 'Gestionnaire de Dépenses',
      
      // Navigation
      dashboard: 'Tableau de Bord',
      transactions: 'Transactions',
      budgets: 'Budgets',
      settings: 'Paramètres',
      
      // Dashboard
      totalIncome: 'Revenu Total',
      totalExpenses: 'Dépenses Totales',
      netBalance: 'Solde Net',
      thisMonth: 'Ce Mois',
      
      // Transactions
      addTransaction: 'Ajouter Transaction',
      income: 'Revenu',
      expense: 'Dépense',
      amount: 'Montant',
      category: 'Catégorie',
      date: 'Date',
      description: 'Description',
      paymentMethod: 'Mode de Paiement',
      type: 'Type',
      
      // Categories
      categories: 'Catégories',
      incomeCategories: 'Catégories de Revenu',
      expenseCategories: 'Catégories de Dépense',
      addCategory: 'Ajouter Catégorie',
      categoryName: 'Nom de Catégorie',
      categoryColor: 'Couleur de Catégorie',
      
      // Predefined Categories - Expense
      food: 'Nourriture',
      transport: 'Transport',
      shopping: 'Achats',
      bills: 'Factures',
      entertainment: 'Divertissement',
      health: 'Santé',
      education: 'Éducation',
      other: 'Autre',
      
      // Predefined Categories - Income
      salary: 'Salaire',
      freelance: 'Freelance',
      investment: 'Investissement',
      gift: 'Cadeau',
      
      // Payment Methods
      cash: 'Espèces',
      card: 'Carte',
      bankTransfer: 'Virement Bancaire',
      digitalWallet: 'Portefeuille Numérique',
      
      // Filters
      filter: 'Filtrer',
      filterBy: 'Filtrer Par',
      sortBy: 'Trier Par',
      search: 'Rechercher',
      clearFilters: 'Effacer Filtres',
      all: 'Tout',
      
      // Sort Options
      newest: 'Plus Récent',
      oldest: 'Plus Ancien',
      highestAmount: 'Montant Plus Élevé',
      lowestAmount: 'Montant Plus Bas',
      
      // Budgets
      setBudget: 'Définir Budget',
      monthlyBudget: 'Budget Mensuel',
      budgetLimit: 'Limite de Budget',
      spent: 'Dépensé',
      remaining: 'Restant',
      
      // Recurring
      recurring: 'Récurrent',
      frequency: 'Fréquence',
      daily: 'Quotidien',
      weekly: 'Hebdomadaire',
      monthly: 'Mensuel',
      yearly: 'Annuel',
      
      // Currency
      currency: 'Devise',
      baseCurrency: 'Devise de Base',
      exchangeRate: 'Taux de Change',
      customRates: 'Taux Personnalisés',
      
      // Export
      export: 'Exporter',
      exportCSV: 'Exporter CSV',
      exportJSON: 'Exporter JSON',
      
      // Settings
      language: 'Langue',
      theme: 'Thème',
      darkMode: 'Mode Sombre',
      lightMode: 'Mode Clair',
      
      // Actions
      save: 'Enregistrer',
      cancel: 'Annuler',
      delete: 'Supprimer',
      edit: 'Modifier',
      add: 'Ajouter',
      close: 'Fermer',
      confirm: 'Confirmer',
      
      // Messages
      transactionAdded: 'Transaction ajoutée avec succès',
      transactionUpdated: 'Transaction mise à jour avec succès',
      transactionDeleted: 'Transaction supprimée avec succès',
      budgetExceeded: 'Budget dépassé!',
      budgetWarning: 'Vous approchez de votre limite de budget',
      noTransactions: 'Aucune transaction',
      
      // Charts
      incomeVsExpense: 'Revenu vs Dépense',
      expenseBreakdown: 'Répartition des Dépenses',
      incomeBreakdown: 'Répartition des Revenus',
      monthlyTrend: 'Tendance Mensuelle',
      balanceTrend: 'Tendance du Solde',
    },
    
    ar: {
      // App Title
      appTitle: 'متتبع النفقات',
      
      // Navigation
      dashboard: 'لوحة التحكم',
      transactions: 'المعاملات',
      budgets: 'الميزانيات',
      settings: 'الإعدادات',
      
      // Dashboard
      totalIncome: 'إجمالي الدخل',
      totalExpenses: 'إجمالي النفقات',
      netBalance: 'الرصيد الصافي',
      thisMonth: 'هذا الشهر',
      
      // Transactions
      addTransaction: 'إضافة معاملة',
      income: 'دخل',
      expense: 'نفقة',
      amount: 'المبلغ',
      category: 'الفئة',
      date: 'التاريخ',
      description: 'الوصف',
      paymentMethod: 'طريقة الدفع',
      type: 'النوع',
      
      // Categories
      categories: 'الفئات',
      incomeCategories: 'فئات الدخل',
      expenseCategories: 'فئات النفقات',
      addCategory: 'إضافة فئة',
      categoryName: 'اسم الفئة',
      categoryColor: 'لون الفئة',
      
      // Predefined Categories - Expense
      food: 'طعام',
      transport: 'نقل',
      shopping: 'تسوق',
      bills: 'فواتير',
      entertainment: 'ترفيه',
      health: 'صحة',
      education: 'تعليم',
      other: 'أخرى',
      
      // Predefined Categories - Income
      salary: 'راتب',
      freelance: 'عمل حر',
      investment: 'استثمار',
      gift: 'هدية',
      
      // Payment Methods
      cash: 'نقدي',
      card: 'بطاقة',
      bankTransfer: 'تحويل بنكي',
      digitalWallet: 'محفظة رقمية',
      
      // Filters
      filter: 'تصفية',
      filterBy: 'تصفية حسب',
      sortBy: 'ترتيب حسب',
      search: 'بحث',
      clearFilters: 'مسح الفلاتر',
      all: 'الكل',
      
      // Sort Options
      newest: 'الأحدث أولاً',
      oldest: 'الأقدم أولاً',
      highestAmount: 'أعلى مبلغ',
      lowestAmount: 'أقل مبلغ',
      
      // Budgets
      setBudget: 'تعيين ميزانية',
      monthlyBudget: 'الميزانية الشهرية',
      budgetLimit: 'حد الميزانية',
      spent: 'تم إنفاقه',
      remaining: 'المتبقي',
      
      // Recurring
      recurring: 'متكرر',
      frequency: 'التكرار',
      daily: 'يومي',
      weekly: 'أسبوعي',
      monthly: 'شهري',
      yearly: 'سنوي',
      
      // Currency
      currency: 'العملة',
      baseCurrency: 'العملة الأساسية',
      exchangeRate: 'سعر الصرف',
      customRates: 'أسعار مخصصة',
      
      // Export
      export: 'تصدير',
      exportCSV: 'تصدير CSV',
      exportJSON: 'تصدير JSON',
      
      // Settings
      language: 'اللغة',
      theme: 'السمة',
      darkMode: 'الوضع الداكن',
      lightMode: 'الوضع الفاتح',
      
      // Actions
      save: 'حفظ',
      cancel: 'إلغاء',
      delete: 'حذف',
      edit: 'تعديل',
      add: 'إضافة',
      close: 'إغلاق',
      confirm: 'تأكيد',
      
      // Messages
      transactionAdded: 'تمت إضافة المعاملة بنجاح',
      transactionUpdated: 'تم تحديث المعاملة بنجاح',
      transactionDeleted: 'تم حذف المعاملة بنجاح',
      budgetExceeded: 'تم تجاوز الميزانية!',
      budgetWarning: 'أنت تقترب من حد ميزانيتك',
      noTransactions: 'لا توجد معاملات',
      
      // Charts
      incomeVsExpense: 'الدخل مقابل النفقات',
      expenseBreakdown: 'توزيع النفقات',
      incomeBreakdown: 'توزيع الدخل',
      monthlyTrend: 'الاتجاه الشهري',
      balanceTrend: 'اتجاه الرصيد',
    },
    
    zh: {
      // App Title
      appTitle: '支出追踪器',
      
      // Navigation
      dashboard: '仪表板',
      transactions: '交易',
      budgets: '预算',
      settings: '设置',
      
      // Dashboard
      totalIncome: '总收入',
      totalExpenses: '总支出',
      netBalance: '净余额',
      thisMonth: '本月',
      
      // Transactions
      addTransaction: '添加交易',
      income: '收入',
      expense: '支出',
      amount: '金额',
      category: '类别',
      date: '日期',
      description: '描述',
      paymentMethod: '支付方式',
      type: '类型',
      
      // Categories
      categories: '类别',
      incomeCategories: '收入类别',
      expenseCategories: '支出类别',
      addCategory: '添加类别',
      categoryName: '类别名称',
      categoryColor: '类别颜色',
      
      // Predefined Categories - Expense
      food: '食品',
      transport: '交通',
      shopping: '购物',
      bills: '账单',
      entertainment: '娱乐',
      health: '健康',
      education: '教育',
      other: '其他',
      
      // Predefined Categories - Income
      salary: '工资',
      freelance: '自由职业',
      investment: '投资',
      gift: '礼物',
      
      // Payment Methods
      cash: '现金',
      card: '卡',
      bankTransfer: '银行转账',
      digitalWallet: '数字钱包',
      
      // Filters
      filter: '筛选',
      filterBy: '筛选方式',
      sortBy: '排序方式',
      search: '搜索',
      clearFilters: '清除筛选',
      all: '全部',
      
      // Sort Options
      newest: '最新优先',
      oldest: '最旧优先',
      highestAmount: '金额最高',
      lowestAmount: '金额最低',
      
      // Budgets
      setBudget: '设置预算',
      monthlyBudget: '月度预算',
      budgetLimit: '预算限额',
      spent: '已花费',
      remaining: '剩余',
      
      // Recurring
      recurring: '重复',
      frequency: '频率',
      daily: '每日',
      weekly: '每周',
      monthly: '每月',
      yearly: '每年',
      
      // Currency
      currency: '货币',
      baseCurrency: '基础货币',
      exchangeRate: '汇率',
      customRates: '自定义汇率',
      
      // Export
      export: '导出',
      exportCSV: '导出 CSV',
      exportJSON: '导出 JSON',
      
      // Settings
      language: '语言',
      theme: '主题',
      darkMode: '深色模式',
      lightMode: '浅色模式',
      
      // Actions
      save: '保存',
      cancel: '取消',
      delete: '删除',
      edit: '编辑',
      add: '添加',
      close: '关闭',
      confirm: '确认',
      
      // Messages
      transactionAdded: '交易添加成功',
      transactionUpdated: '交易更新成功',
      transactionDeleted: '交易删除成功',
      budgetExceeded: '超出预算！',
      budgetWarning: '您即将达到预算限额',
      noTransactions: '暂无交易',
      
      // Charts
      incomeVsExpense: '收入 vs 支出',
      expenseBreakdown: '支出明细',
      incomeBreakdown: '收入明细',
      monthlyTrend: '月度趋势',
      balanceTrend: '余额趋势',
    }
  },
  
  // Get translated text
  t(key) {
    return this.translations[this.currentLanguage][key] || key;
  },
  
  // Set language
  setLanguage(lang) {
    if (this.translations[lang]) {
      this.currentLanguage = lang;
      localStorage.setItem('language', lang);
      
      // Apply RTL for Arabic
      document.documentElement.setAttribute('dir', lang === 'ar' ? 'rtl' : 'ltr');
      document.documentElement.setAttribute('lang', lang);
      
      // Update UI
      this.updateUI();
    }
  },
  
  // Update all UI text
  updateUI() {
    document.querySelectorAll('[data-i18n]').forEach(element => {
      const key = element.getAttribute('data-i18n');
      element.textContent = this.t(key);
    });
    
    document.querySelectorAll('[data-i18n-placeholder]').forEach(element => {
      const key = element.getAttribute('data-i18n-placeholder');
      element.placeholder = this.t(key);
    });
    
    // Update page title
    document.title = this.t('appTitle');
  },
  
  // Format currency
  formatCurrency(amount, currency = 'USD') {
    const localeMap = {
      en: 'en-US',
      fr: 'fr-FR',
      ar: 'ar-SA',
      zh: 'zh-CN'
    };
    
    return new Intl.NumberFormat(localeMap[this.currentLanguage], {
      style: 'currency',
      currency: currency
    }).format(amount);
  },
  
  // Format number
  formatNumber(number) {
    const localeMap = {
      en: 'en-US',
      fr: 'fr-FR',
      ar: 'ar-SA',
      zh: 'zh-CN'
    };
    
    return new Intl.NumberFormat(localeMap[this.currentLanguage]).format(number);
  },
  
  // Format date
  formatDate(date) {
    const localeMap = {
      en: 'en-US',
      fr: 'fr-FR',
      ar: 'ar-SA',
      zh: 'zh-CN'
    };
    
    return new Intl.DateTimeFormat(localeMap[this.currentLanguage], {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    }).format(new Date(date));
  },
  
  // Initialize
  init() {
    // Set initial language and direction
    const lang = this.currentLanguage;
    document.documentElement.setAttribute('dir', lang === 'ar' ? 'rtl' : 'ltr');
    document.documentElement.setAttribute('lang', lang);
    
    // Update UI when DOM is ready
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => this.updateUI());
    } else {
      this.updateUI();
    }
  }
};

// Initialize i18n
i18n.init();
