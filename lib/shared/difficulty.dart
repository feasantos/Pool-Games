enum Difficulty { sabricinha, alicinha, pierrote, feliposo }

extension DifficultyLabel on Difficulty {
  String get label => switch (this) {
        Difficulty.sabricinha => 'Sabricinha',
        Difficulty.alicinha => 'Alicinha',
        Difficulty.pierrote => 'Pierrote',
        Difficulty.feliposo => 'Feliposo',
      };
}
