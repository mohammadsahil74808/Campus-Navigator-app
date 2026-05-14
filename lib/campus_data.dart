import 'package:campus_prototype/data/computing_block.dart';
import 'package:campus_prototype/data/architecture_block.dart';
import 'package:campus_prototype/data/central_block.dart';
import 'package:campus_prototype/data/other_blocks.dart';

// Core blocks for the "Open Blocks/Rooms" UI list
final List<Map<String, dynamic>> campusBlocks = [
  computingBlock,
  architectureBlock,
  centralBlock,
  komatiBlock,
  libraryBlock,
];

// All blocks for the "Open Campus Map" screen
final List<Map<String, dynamic>> allCampusBlocks = [
  ...campusBlocks,
  girlsHostelBlock,
  canteenBlock,
  musicAndDanceBlock,
  gymAndNssBlock,
  lawnTennisBlock,
  messBlock,
  parkingBlock,
];
