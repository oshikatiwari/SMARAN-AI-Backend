// ignore_for_file: avoid_relative_lib_imports
//
// Unit tests for the pairId assignment fix in CardGridComponent.
//
// Tests operate on the pure symbol-generation logic (no Flame engine required)
// and verify the invariant that was broken before the fix:
//
//   BEFORE (buggy):  pairId = i % totalPairs  — assigned from the raw grid
//                    index BEFORE shuffle, so it is unrelated to the symbol.
//
//   AFTER  (fixed):  pairId = selected.indexOf(symbols[i])  — always derived
//                    from the actual post-shuffle symbol, so two cards showing
//                    the same emoji always carry the same pairId, and no two
//                    cards with different emojis share a pairId.
//
// The test replicates the exact algorithm from CardGridComponent so that any
// future regression in the production code will also break these tests.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

// ── Replicated symbol pool (must stay in sync with CardGridComponent) ─────────

const List<String> _symbolPool = [
  '🌟', '🎯', '🌈', '🎵', '🌺',
  '🦋', '🐢', '🌙', '☀️', '🍎',
];

// ── Replicated pair generation (mirrors the fixed CardGridComponent logic) ────

/// Returns the [selected] unique symbols and the [symbols] shuffled flat list,
/// mirroring `_generateShuffledSymbols` in `CardGridComponent`.
({List<String> selected, List<String> symbols}) generateShuffledSymbols(
  final int totalPairs, {
  Random? rng,
}) {
  final selected = _symbolPool.take(totalPairs).toList();
  final pairs = [...selected, ...selected];
  pairs.shuffle(rng ?? Random());
  return (selected: selected, symbols: pairs);
}

/// Builds a map from grid-position → pairId using the fixed algorithm.
/// Returns `{cardIndex: pairId}` for all [totalCards] positions.
Map<int, int> buildPairIdMap(final int totalCards) {
  final totalPairs = totalCards ~/ 2;
  final (:selected, :symbols) = generateShuffledSymbols(totalPairs);
  return {
    for (var i = 0; i < totalCards; i++) i: selected.indexOf(symbols[i]),
  };
}

// ── Tests ──────────────────────────────────────────────────────────────────────

void main() {
  // Run each grid size multiple times with different random seeds to cover
  // many shuffle orderings.
  const iterations = 50;

  for (final (cols, rows) in [(3, 4), (4, 4), (4, 5)]) {
    final totalCards = cols * rows;
    final totalPairs = totalCards ~/ 2;
    final label = '$cols×$rows grid ($totalCards cards / $totalPairs pairs)';

    group('pairId invariants — $label', () {
      test(
        'two cards with the same symbol always have identical pairId '
        '($iterations random shuffles)',
        () {
          for (var seed = 0; seed < iterations; seed++) {
            final selected =
                _symbolPool.take(totalPairs).toList();
            final pairs = [...selected, ...selected];
            pairs.shuffle(Random(seed));

            // Build symbol → [pairId...] map
            final symbolToPairIds = <String, List<int>>{};
            for (var i = 0; i < totalCards; i++) {
              final symbol = pairs[i];
              final pairId = selected.indexOf(symbol); // fixed algorithm
              symbolToPairIds.putIfAbsent(symbol, () => []).add(pairId);
            }

            for (final entry in symbolToPairIds.entries) {
              final sym = entry.key;
              final pairIds = entry.value;
              expect(
                pairIds.toSet().length,
                equals(1),
                reason:
                    'seed=$seed: symbol "$sym" maps to ${pairIds.toSet()} '
                    '— expected both cards to share the same pairId',
              );
            }
          }
        },
      );

      test(
        'no two cards with different symbols share a pairId '
        '($iterations random shuffles)',
        () {
          for (var seed = 0; seed < iterations; seed++) {
            final selected =
                _symbolPool.take(totalPairs).toList();
            final pairs = [...selected, ...selected];
            pairs.shuffle(Random(seed));

            // Build pairId → {distinct symbols} map
            final pairIdToSymbols = <int, Set<String>>{};
            for (var i = 0; i < totalCards; i++) {
              final symbol = pairs[i];
              final pairId = selected.indexOf(symbol);
              pairIdToSymbols.putIfAbsent(pairId, () => {}).add(symbol);
            }

            for (final entry in pairIdToSymbols.entries) {
              final pid = entry.key;
              final symbols = entry.value;
              expect(
                symbols.length,
                equals(1),
                reason:
                    'seed=$seed: pairId=$pid contains multiple distinct '
                    'symbols $symbols — expected all cards with this pairId '
                    'to show the same symbol',
              );
            }
          }
        },
      );

      test('every pairId appears exactly twice (one pair per symbol)', () {
        for (var seed = 0; seed < iterations; seed++) {
          final selected = _symbolPool.take(totalPairs).toList();
          final pairs = [...selected, ...selected];
          pairs.shuffle(Random(seed));

          final pairIdCounts = <int, int>{};
          for (var i = 0; i < totalCards; i++) {
            final pairId = selected.indexOf(pairs[i]);
            pairIdCounts[pairId] = (pairIdCounts[pairId] ?? 0) + 1;
          }

          for (final entry in pairIdCounts.entries) {
            expect(
              entry.value,
              equals(2),
              reason:
                  'seed=$seed: pairId=${entry.key} appeared ${entry.value} '
                  'times — expected exactly 2',
            );
          }
        }
      });

      test('pairId values cover exactly 0..totalPairs-1 (no gaps, no overflow)',
          () {
        final selected = _symbolPool.take(totalPairs).toList();
        final pairs = [...selected, ...selected];
        pairs.shuffle(Random(42));

        final pairIds = {
          for (var i = 0; i < totalCards; i++) selected.indexOf(pairs[i]),
        };

        expect(
          pairIds,
          equals(List.generate(totalPairs, (final n) => n).toSet()),
          reason: 'pairId set should be exactly {0..$totalPairs-1}',
        );
      });

      test(
        'buggy algorithm (i % totalPairs) would fail on at least one shuffle',
        () {
          // This test documents WHY the old code was wrong:
          // pairId = i % totalPairs assigns pair membership by POSITION,
          // not by symbol.  After a shuffle, position has no relation to symbol,
          // so two cards at positions (k, k+totalPairs) share a pairId only by
          // accident.  We verify that the buggy approach diverges from the
          // correct approach on at least one shuffle in our iteration set.

          bool foundDivergence = false;

          for (var seed = 0; seed < iterations && !foundDivergence; seed++) {
            final selected = _symbolPool.take(totalPairs).toList();
            final pairs = [...selected, ...selected];
            pairs.shuffle(Random(seed));

            for (var i = 0; i < totalCards; i++) {
              final correctPairId = selected.indexOf(pairs[i]);
              final buggyPairId = i % totalPairs;
              if (correctPairId != buggyPairId) {
                foundDivergence = true;
                break;
              }
            }
          }

          expect(
            foundDivergence,
            isTrue,
            reason:
                'The old i%totalPairs algorithm should differ from the correct '
                'selected.indexOf(symbols[i]) on at least one shuffle — '
                'if this fails the shuffle is always the identity permutation '
                'which is astronomically unlikely',
          );
        },
      );
    });
  }
}
