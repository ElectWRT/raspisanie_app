import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/substitution.dart';
import '../bloc/substitutions_bloc.dart';
import '../widgets/substitution_card.dart';

class SubstitutionsPage extends StatelessWidget {
  const SubstitutionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Замены в расписании'),
        actions: [
          IconButton(
            onPressed: () => context.read<SubstitutionsBloc>().add(const RefreshSubstitutions()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocBuilder<SubstitutionsBloc, SubstitutionsState>(
        builder: (context, state) {
          if (state is SubstitutionsError) {
            return _ErrorView(message: state.message);
          }

          final isLoading = state is SubstitutionsLoading;
          final items = state is SubstitutionsLoaded ? state.items : _dummyData;

          return Skeletonizer(
            enabled: isLoading,
            child: items.isEmpty && !isLoading
                ? const _EmptyView()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return SubstitutionCard(substitution: items[index])
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: 50 * index))
                          .slideX(begin: 0.1);
                    },
                  ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.read<SubstitutionsBloc>().add(const RefreshSubstitutions()),
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Замен нет'));
  }
}

final _dummyData = List.generate(
  5,
  (index) => SubstitutionEntity(
    id: index,
    groupName: 'СА-2123',
    subject: 'Предмет для скелетона',
    teacher: 'Преподаватель И.О.',
    room: '404',
    period: '1 пара',
  ),
);
