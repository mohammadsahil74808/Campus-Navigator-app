import 'data/computing_block.dart';
import 'data/architecture_block.dart';
import 'data/pharmacy_block.dart';
import 'data/central_block.dart';
import 'data/other_blocks.dart';

// Core blocks for the "Open Blocks/Rooms" UI list
final List<Map<String, dynamic>> campusBlocks = [
  computingBlock,
  architectureBlock,
  pharmacyBlock,
  centralBlock,
];

// All blocks for the "Open Campus Map" screen
final List<Map<String, dynamic>> allCampusBlocks = [
  ...campusBlocks,
  girlsHostelBlock,
  libraryBlock,
  canteenBlock,
  musicAndDanceBlock,
  gymAndNssBlock,
  lawnTennisBlock,
  messBlock,
  parkingBlock,
  komatiBlock,
];
