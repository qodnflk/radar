import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/portfolio_item.dart';
import '../theme/app_theme.dart';

class PortfolioCard extends StatelessWidget {
  final PortfolioItem item;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PortfolioCard({
    super.key,
    required this.item,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currentValue = item.totalValue;
    final investedAmount = item.shares * item.averagePrice;
    final profitLoss = currentValue - investedAmount;
    final profitLossPercentage = (profitLoss / investedAmount) * 100;
    final isProfit = profitLoss >= 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: AppTheme.primaryNavy.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: AppTheme.dividerGray.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row - Symbol and Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Stock Symbol and Name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.symbol,
                              style: FinancialTextStyles.stockSymbol.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Action Buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (onEdit != null)
                            IconButton(
                              onPressed: onEdit,
                              icon: const Icon(Icons.edit_outlined),
                              iconSize: 20,
                              style: IconButton.styleFrom(
                                foregroundColor: AppTheme.textSecondary,
                                backgroundColor: AppTheme.surfaceGray,
                                minimumSize: const Size(36, 36),
                              ),
                              tooltip: '수정',
                            ),
                          const SizedBox(width: 8),
                          if (onDelete != null)
                            IconButton(
                              onPressed: onDelete,
                              icon: const Icon(Icons.delete_outline),
                              iconSize: 20,
                              style: IconButton.styleFrom(
                                foregroundColor: AppTheme.errorRed,
                                backgroundColor:
                                    AppTheme.errorRed.withValues(alpha: 0.1),
                                minimumSize: const Size(36, 36),
                              ),
                              tooltip: '삭제',
                            ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Financial Information Grid
                  Row(
                    children: [
                      // Left Column - Portfolio Value
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '포트폴리오 가치',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '\$${NumberFormat('#,##0.00').format(currentValue)}',
                              style: FinancialTextStyles.currencyLarge.copyWith(
                                color: AppColors.portfolioValue,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: NumberFormat('#,##0')
                                        .format(item.shares),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppTheme.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  TextSpan(
                                    text: ' 주',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Divider
                      Container(
                        height: 60,
                        width: 1,
                        color: AppTheme.dividerGray,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),

                      // Right Column - Profit/Loss
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '손익',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${isProfit ? '+' : ''}\$${NumberFormat('#,##0.00').format(profitLoss)}',
                              style:
                                  FinancialTextStyles.currencyMedium.copyWith(
                                color: isProfit
                                    ? AppColors.portfolioProfit
                                    : AppColors.portfolioLoss,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (isProfit
                                        ? AppColors.portfolioProfit
                                        : AppColors.portfolioLoss)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${isProfit ? '+' : ''}${profitLossPercentage.toStringAsFixed(1)}%',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: isProfit
                                          ? AppColors.portfolioProfit
                                          : AppColors.portfolioLoss,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Bottom Info Bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceGray,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '평균 매수가',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\$${NumberFormat('#,##0.00').format(item.averagePrice)}',
                              style: FinancialTextStyles.currencySmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '매수일',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('yyyy.MM.dd')
                                  .format(item.purchaseDate),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
