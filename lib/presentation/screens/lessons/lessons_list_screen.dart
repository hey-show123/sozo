import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/curriculum_provider.dart';
import '../../widgets/curriculum_card.dart';

class LessonsListScreen extends ConsumerStatefulWidget {
  const LessonsListScreen({super.key});

  @override
  ConsumerState<LessonsListScreen> createState() => _LessonsListScreenState();
}

class _LessonsListScreenState extends ConsumerState<LessonsListScreen> {
  String _selectedCategory = 'all';
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(curriculumProvider.notifier).loadCurriculums();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final curriculumsAsync = ref.watch(curriculumProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // カスタムAppBar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: theme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'レッスン',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // カテゴリフィルター
          SliverToBoxAdapter(
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryChip('all', 'すべて', Icons.apps),
                  const SizedBox(width: 8),
                  _buildCategoryChip('haircare', 'ヘアケア', Icons.cut),
                  const SizedBox(width: 8),
                  _buildCategoryChip('makeup', 'メイクアップ', Icons.brush),
                  const SizedBox(width: 8),
                  _buildCategoryChip('nail', 'ネイル', Icons.pan_tool),
                  const SizedBox(width: 8),
                  _buildCategoryChip('esthetics', 'エステ', Icons.spa),
                  const SizedBox(width: 8),
                  _buildCategoryChip('coloring', 'カラーリング', Icons.color_lens),
                ],
              ),
            ),
          ),
          
          // レッスン一覧
          curriculumsAsync.when(
            data: (curriculums) {
              final filteredCurriculums = _selectedCategory == 'all'
                  ? curriculums
                  : curriculums.where((c) => 
                      c.category.toLowerCase() == _selectedCategory
                    ).toList();
              
              if (filteredCurriculums.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'レッスンが見つかりません',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final curriculum = filteredCurriculums[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildCurriculumCard(curriculum),
                      );
                    },
                    childCount: filteredCurriculums.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'エラーが発生しました',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(curriculumProvider.notifier).loadCurriculums();
                      },
                      child: const Text('再試行'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryChip(String value, String label, IconData icon) {
    final isSelected = _selectedCategory == value;
    
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      onSelected: (selected) {
        setState(() {
          _selectedCategory = value;
        });
      },
      selectedColor: Theme.of(context).primaryColor,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.grey[200],
      elevation: isSelected ? 4 : 0,
      shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
    );
  }
  
  Widget _buildCurriculumCard(dynamic curriculum) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () {
        ref.read(selectedCurriculumProvider.notifier).state = curriculum;
        context.push('/curriculum/${curriculum.id}');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // カバー画像
            Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getCategoryColors(curriculum.category),
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(curriculum.category),
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
            
            // コンテンツ
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          curriculum.category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '4.5',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    curriculum.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    curriculum.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.signal_cellular_alt, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'レベル ${curriculum.difficultyLevel}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '12レッスン',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
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
    );
  }
  
  List<Color> _getCategoryColors(String category) {
    switch (category.toLowerCase()) {
      case 'haircare':
        return [Colors.blue[400]!, Colors.blue[600]!];
      case 'makeup':
        return [Colors.pink[400]!, Colors.pink[600]!];
      case 'nail':
        return [Colors.purple[400]!, Colors.purple[600]!];
      case 'esthetics':
        return [Colors.green[400]!, Colors.green[600]!];
      case 'coloring':
        return [Colors.orange[400]!, Colors.orange[600]!];
      default:
        return [Colors.grey[400]!, Colors.grey[600]!];
    }
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'haircare':
        return Icons.cut;
      case 'makeup':
        return Icons.brush;
      case 'nail':
        return Icons.pan_tool;
      case 'esthetics':
        return Icons.spa;
      case 'coloring':
        return Icons.color_lens;
      default:
        return Icons.school;
    }
  }
} 