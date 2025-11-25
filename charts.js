// Charts Module
let chartInstances = {
    incomeExpense: null,
    expenseBreakdown: null,
    monthlyTrend: null
};

function renderCharts(state, i18n) {
    const currentMonth = new Date().toISOString().slice(0, 7);
    const monthTransactions = state.transactions.filter(t => t.date.startsWith(currentMonth));

    // Destroy existing charts
    Object.values(chartInstances).forEach(chart => {
        if (chart) chart.destroy();
    });

    // Render Income vs Expense Chart
    renderIncomeExpenseChart(monthTransactions, i18n);

    // Render Expense Breakdown Chart
    renderExpenseBreakdownChart(monthTransactions, state, i18n);

    // Render Monthly Trend Chart
    renderMonthlyTrendChart(state, i18n);
}

function renderIncomeExpenseChart(transactions, i18n) {
    const ctx = document.getElementById('incomeExpenseChart');
    if (!ctx) return;

    const income = transactions
        .filter(t => t.type === 'income')
        .reduce((sum, t) => sum + t.amount, 0);

    const expense = transactions
        .filter(t => t.type === 'expense')
        .reduce((sum, t) => sum + t.amount, 0);

    chartInstances.incomeExpense = new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: [i18n.t('income'), i18n.t('expense')],
            datasets: [{
                data: [income, expense],
                backgroundColor: [
                    'rgba(16, 185, 129, 0.8)',
                    'rgba(239, 68, 68, 0.8)'
                ],
                borderColor: [
                    'rgba(16, 185, 129, 1)',
                    'rgba(239, 68, 68, 1)'
                ],
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {
                        padding: 15,
                        font: {
                            family: 'Inter',
                            size: 12
                        },
                        usePointStyle: true,
                        pointStyle: 'circle'
                    }
                },
                tooltip: {
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    padding: 12,
                    cornerRadius: 8,
                    titleFont: {
                        family: 'Inter',
                        size: 14,
                        weight: '600'
                    },
                    bodyFont: {
                        family: 'Inter',
                        size: 13
                    },
                    callbacks: {
                        label: function (context) {
                            const label = context.label || '';
                            const value = i18n.formatCurrency(context.parsed, app.state.settings.currency);
                            const total = context.dataset.data.reduce((a, b) => a + b, 0);
                            const percentage = total > 0 ? ((context.parsed / total) * 100).toFixed(1) : 0;
                            return `${label}: ${value} (${percentage}%)`;
                        }
                    }
                }
            },
            cutout: '65%'
        }
    });
}

function renderExpenseBreakdownChart(transactions, state, i18n) {
    const ctx = document.getElementById('expenseBreakdownChart');
    if (!ctx) return;

    const expenseTransactions = transactions.filter(t => t.type === 'expense');

    // Group by category
    const categoryTotals = {};
    const categoryColors = {};

    expenseTransactions.forEach(t => {
        if (!categoryTotals[t.categoryId]) {
            categoryTotals[t.categoryId] = 0;
            categoryColors[t.categoryId] = t.color;
        }
        categoryTotals[t.categoryId] += t.amount;
    });

    const labels = Object.keys(categoryTotals).map(id => {
        const category = state.categories.expense.find(c => c.id === id);
        return `${category?.icon || ''} ${i18n.t(id) || id}`;
    });

    const data = Object.values(categoryTotals);
    const colors = Object.keys(categoryTotals).map(id => categoryColors[id]);

    chartInstances.expenseBreakdown = new Chart(ctx, {
        type: 'pie',
        data: {
            labels: labels,
            datasets: [{
                data: data,
                backgroundColor: colors.map(c => c + 'CC'),
                borderColor: colors,
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {
                        padding: 10,
                        font: {
                            family: 'Inter',
                            size: 11
                        },
                        usePointStyle: true,
                        pointStyle: 'circle'
                    }
                },
                tooltip: {
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    padding: 12,
                    cornerRadius: 8,
                    titleFont: {
                        family: 'Inter',
                        size: 14,
                        weight: '600'
                    },
                    bodyFont: {
                        family: 'Inter',
                        size: 13
                    },
                    callbacks: {
                        label: function (context) {
                            const label = context.label || '';
                            const value = i18n.formatCurrency(context.parsed, app.state.settings.currency);
                            const total = context.dataset.data.reduce((a, b) => a + b, 0);
                            const percentage = total > 0 ? ((context.parsed / total) * 100).toFixed(1) : 0;
                            return `${label}: ${value} (${percentage}%)`;
                        }
                    }
                }
            }
        }
    });
}

function renderMonthlyTrendChart(state, i18n) {
    const ctx = document.getElementById('monthlyTrendChart');
    if (!ctx) return;

    // Get last 6 months
    const months = [];
    const now = new Date();

    for (let i = 5; i >= 0; i--) {
        const date = new Date(now.getFullYear(), now.getMonth() - i, 1);
        months.push(date.toISOString().slice(0, 7));
    }

    // Calculate income and expense for each month
    const incomeData = months.map(month => {
        return state.transactions
            .filter(t => t.type === 'income' && t.date.startsWith(month))
            .reduce((sum, t) => sum + t.amount, 0);
    });

    const expenseData = months.map(month => {
        return state.transactions
            .filter(t => t.type === 'expense' && t.date.startsWith(month))
            .reduce((sum, t) => sum + t.amount, 0);
    });

    // Format month labels
    const labels = months.map(month => {
        const date = new Date(month + '-01');
        return date.toLocaleDateString(i18n.currentLanguage === 'ar' ? 'ar-SA' :
            i18n.currentLanguage === 'fr' ? 'fr-FR' :
                i18n.currentLanguage === 'zh' ? 'zh-CN' : 'en-US',
            { month: 'short', year: 'numeric' });
    });

    chartInstances.monthlyTrend = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [
                {
                    label: i18n.t('income'),
                    data: incomeData,
                    borderColor: 'rgba(16, 185, 129, 1)',
                    backgroundColor: 'rgba(16, 185, 129, 0.1)',
                    borderWidth: 3,
                    fill: true,
                    tension: 0.4,
                    pointRadius: 5,
                    pointHoverRadius: 7,
                    pointBackgroundColor: 'rgba(16, 185, 129, 1)',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2
                },
                {
                    label: i18n.t('expense'),
                    data: expenseData,
                    borderColor: 'rgba(239, 68, 68, 1)',
                    backgroundColor: 'rgba(239, 68, 68, 0.1)',
                    borderWidth: 3,
                    fill: true,
                    tension: 0.4,
                    pointRadius: 5,
                    pointHoverRadius: 7,
                    pointBackgroundColor: 'rgba(239, 68, 68, 1)',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            interaction: {
                intersect: false,
                mode: 'index'
            },
            plugins: {
                legend: {
                    position: 'top',
                    align: 'end',
                    labels: {
                        padding: 15,
                        font: {
                            family: 'Inter',
                            size: 12,
                            weight: '500'
                        },
                        usePointStyle: true,
                        pointStyle: 'circle',
                        boxWidth: 8
                    }
                },
                tooltip: {
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    padding: 12,
                    cornerRadius: 8,
                    titleFont: {
                        family: 'Inter',
                        size: 14,
                        weight: '600'
                    },
                    bodyFont: {
                        family: 'Inter',
                        size: 13
                    },
                    callbacks: {
                        label: function (context) {
                            const label = context.dataset.label || '';
                            const value = i18n.formatCurrency(context.parsed.y, app.state.settings.currency);
                            return `${label}: ${value}`;
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)',
                        drawBorder: false
                    },
                    ticks: {
                        font: {
                            family: 'Inter',
                            size: 11
                        },
                        padding: 10,
                        callback: function (value) {
                            return i18n.formatNumber(value);
                        }
                    }
                },
                x: {
                    grid: {
                        display: false,
                        drawBorder: false
                    },
                    ticks: {
                        font: {
                            family: 'Inter',
                            size: 11
                        },
                        padding: 10
                    }
                }
            }
        }
    });
}

// Export for use in app.js
window.renderCharts = renderCharts;
