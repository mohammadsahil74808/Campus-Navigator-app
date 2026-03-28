import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CampusUIScreen(),
    );
  }
}

class CampusUIScreen extends StatefulWidget {
  const CampusUIScreen({super.key});

  @override
  State<CampusUIScreen> createState() => _CampusUIScreenState();
}

class _CampusUIScreenState extends State<CampusUIScreen> {
  TextEditingController searchController = TextEditingController();
String searchQuery = "";

  final List<Map<String, dynamic>> _blocks = [
  {
  "name": "Computing Block",
  "lat": 28.409111,
  "lng": 77.403222,
  "rooms": [

    /* First Floor */
    {"name": "2101 DBMS Lab (CSE Dept)", "floor": 1, "directions": "From the main staircase, take the first right, then take a left turn; the lab is on the left side."},
    {"name": "CSE Office", "floor": 1, "directions": "From the main staircase, take the first right; the office is on the right side."},
    {"name": "2103", "floor": 1, "directions": "From the main staircase, take the first right; the room is in front of the CSE office."},
    {"name": "2119 HOD CSE Office", "floor": 1, "directions": "From the main staircase, take the first right and walk straight; the HOD cabin is ahead."},
    {"name": "2105", "floor": 1, "directions": "From the main staircase, take the first right and walk straight; the room is straight ahead."},
    {"name": "2120", "floor": 1, "directions": "From the main staircase, take the first right and continue straight; the room is ahead."},
    {"name": "2107", "floor": 1, "directions": "From the main staircase, take the first right and walk straight; the room is directly ahead."},
    {"name": "2121", "floor": 1, "directions": "From the main staircase, take the first right, then take the next right turn; the room is on the right."},
    {"name": "2108", "floor": 1, "directions": "From the main staircase, take the first right, then right; the room is opposite 2121."},
    {"name": "2122", "floor": 1, "directions": "From the main staircase, take the first right, then right; the room is next to 2121."},
    {"name": "2109", "floor": 1, "directions": "From the main staircase, take the first right; the room is opposite 2122."},
    {"name": "2123", "floor": 1, "directions": "From the main staircase, take the first right and walk straight; the room is ahead."},
    {"name": "2124", "floor": 1, "directions": "From the main staircase, take the first right; the room is next to 2123."},
    {"name": "2110", "floor": 1, "directions": "From the main staircase, take the first right and walk straight; the room is ahead."},
    {"name": "2111", "floor": 1, "directions": "From the main staircase, take the first right, then take the next right cut; the room is straight ahead."},
    {"name": "2112 IoT Lab", "floor": 1, "directions": "From the main staircase, take the first right, then take the next right cut; the lab is on the right side."},
    {"name": "2125", "floor": 1, "directions": "From the main staircase, take the first right and walk straight; the room is ahead."},
    {"name": "2113 ECE Computing Lab", "floor": 1, "directions": "From the main staircase, take the first right and walk straight; the lab is ahead."},
    {"name": "2114", "floor": 1, "directions": "From the main staircase, take the first right and continue straight; the room is ahead."},
    {"name": "2126 Faculty Room", "floor": 1, "directions": "From the main staircase, take the first right; the room is ahead on the left side."},
    {"name": "2127 Faculty Room", "floor": 1, "directions": "From the main staircase, take the first right; the room is next to 2126."},
    {"name": "2115", "floor": 1, "directions": "From the main staircase, take the first right; the room is opposite 2127."},
    {"name": "2116", "floor": 1, "directions": "From the main staircase, take the first right, then take a right turn; the room is on the right."},
    {"name": "2117 IT Store Room", "floor": 1, "directions": "From the main staircase, take the first right; the room is straight ahead after 2116."},


    /* Second Floor */
    {"name": "2201", "floor": 2, "directions": "From the main staircase, take the first right; the room is on the right side."},
    {"name": "2201B", "floor": 2, "directions": "From the main staircase, take the first right and walk straight; the room is ahead."},
    {"name": "2209", "floor": 2, "directions": "From the main staircase, take the first right, then the next right; the room is ahead."},
    {"name": "2202A", "floor": 2, "directions": "From the main staircase, take the first right; the room is opposite 2209."},
    {"name": "2202B", "floor": 2, "directions": "From the main staircase, take the first right and walk straight; the room is ahead."},
    {"name": "2203A", "floor": 2, "directions": "From the main staircase, take the first right and walk straight; the room is ahead on right."},
    {"name": "2211 Faculty Room", "floor": 2, "directions": "From the main staircase, take the first right and continue; the room is straight ahead."},
    {"name": "2203B", "floor": 2, "directions": "From the main staircase, take the first right; the room is opposite 2211."},
    {"name": "2204 CSE Dept Library", "floor": 2, "directions": "From the main staircase, take the first right, then the next right; the library is straight ahead."},
    {"name": "HOD CSE (Dr Kundan Singh)", "floor": 2, "directions": "From the main staircase, take the first right; the cabin is opposite the library."},
    {"name": "School of Agriculture Dept Library", "floor": 2, "directions": "From the main staircase, take the first right and continue; the library is ahead."},
    {"name": "2205 IBM Center of Excellence Lab", "floor": 2, "directions": "From the main staircase, take the first right and walk straight; the lab is ahead."},
    {"name": "2214", "floor": 2, "directions": "From the main staircase, take the first right; the room is ahead."},
    {"name": "2215 Faculty Room", "floor": 2, "directions": "From the main staircase, take the first right; the cabin is next to 2214."},
    {"name": "2206A Agriculture Lab", "floor": 2, "directions": "From the main staircase, take the first right; then take a right turn; the lab is on the right."},
    {"name": "2206B Agriculture Lab", "floor": 2, "directions": "From the main staircase, take the first right and walk straight; the lab is ahead."},
    {"name": "Molecular Biology Lab", "floor": 2, "directions": "From the main staircase, take the first right and continue straight; the lab is ahead."},
    {"name": "2217 Cell Structure Lab", "floor": 2, "directions": "From the main staircase, take the first right; the lab is opposite Molecular Biology Lab."},
    {"name": "2218", "floor": 2, "directions": "From the main staircase, take the first right; the room is ahead."},
    {"name": "Bio Process Lab", "floor": 2, "directions": "From the main staircase, take the first right; the lab is opposite 2218."},
    {"name": "2208A", "floor": 2, "directions": "From the main staircase, take the first right, then take a left turn; the lab is on the left."},
    {"name": "2208B", "floor": 2, "directions": "From the main staircase, take the first right, then take a right; the lab is on the right."},


    /* Third Floor */
    {"name": "2314", "floor": 3, "directions": "From the staircase, take the first right; the room is on the right side."},
    {"name": "2301", "floor": 3, "directions": "From the staircase, take the first right and walk straight; the room is ahead."},
    {"name": "Department Library", "floor": 3, "directions": "From the staircase, take the first right and walk straight; the library is ahead."},
    {"name": "2315", "floor": 3, "directions": "From the staircase, take the first right, then take another right; the room is ahead."},
    {"name": "2303A", "floor": 3, "directions": "From the staircase, take the first right; the room is opposite 2315."},
    {"name": "2316 HOD Room (Dr Subbarao Chamarthi)", "floor": 3, "directions": "From the staircase, take the first right and go straight; the cabin is ahead."},
    {"name": "2303B", "floor": 3, "directions": "From the staircase, take the first right and walk straight; the room is ahead."},
    {"name": "2304 Digital Electronics Lab", "floor": 3, "directions": "From the staircase, take the first right and continue; the lab is ahead."},
    {"name": "2317 Faculty Room", "floor": 3, "directions": "From the staircase, take the first right and walk ahead; the room is ahead."},
    {"name": "2305 Analog & Digital Communication Lab", "floor": 3, "directions": "From the staircase, take the first right and continue; the lab is ahead."},
    {"name": "2316 Faculty Room", "floor": 3, "directions": "From the staircase, take the first right, then take the next right; the room is on the right."},
    {"name": "2306 Network Theory Lab", "floor": 3, "directions": "From the staircase, take the first right; the lab is opposite 2316."},
    {"name": "2319", "floor": 3, "directions": "From the staircase, take the first right and continue; the room is ahead."},
    {"name": "2307 Electromagnetic Waves Lab", "floor": 3, "directions": "From the staircase, take the first right and walk straight; the lab is ahead."},
    {"name": "2320", "floor": 3, "directions": "From the staircase, take the first right and continue straight; the room is ahead."},
    {"name": "2321 Faculty Room", "floor": 3, "directions": "From the staircase, take the first right and walk ahead; the room is ahead."},
    {"name": "2308", "floor": 3, "directions": "From the staircase, take the first right; the room is ahead."},
    {"name": "2309", "floor": 3, "directions": "From the staircase, take the first right and continue; the room is ahead."},
    {"name": "2322 Faculty Room (Dr Rupak Kumar Dev)", "floor": 3, "directions": "From the staircase, take the first right, then take the next right; the cabin is ahead."},
    {"name": "2310B Project Lab", "floor": 3, "directions": "From the staircase, take the first right and continue straight; the lab is ahead."},
    {"name": "ECE Project Room", "floor": 3, "directions": "From the staircase, take the first right and continue; the room is ahead."},
    {"name": "2323", "floor": 3, "directions": "From the staircase, take the first right; the room is ahead."},
    {"name": "2324", "floor": 3, "directions": "From the staircase, take the first right; the room is ahead."},
    {"name": "2311B ECE Project Room", "floor": 3, "directions": "From the staircase, take the first right; the room is opposite 2324."},
    {"name": "2312", "floor": 3, "directions": "From the staircase, take the first right and continue; the room is ahead."},
    {"name": "2313", "floor": 3, "directions": "From the staircase, take the first right; then take a right turn; the room is ahead."},


    /* Fourth Floor */
    {"name": "2401", "floor": 4, "directions": "From the staircase, take the first right; the room is on the right."},
    {"name": "2402", "floor": 4, "directions": "From the staircase, take the first right and walk straight; the room is ahead."},
    {"name": "2414", "floor": 4, "directions": "From the staircase, take the first right, then the next right; the room is ahead."},
    {"name": "2403", "floor": 4, "directions": "From the staircase, take the first right; the room is opposite 2414."},
    {"name": "2415", "floor": 4, "directions": "From the staircase, take the first right and walk straight; the room is ahead."},
    {"name": "2404", "floor": 4, "directions": "From the staircase, take the first right and continue; the room is ahead."},
    {"name": "2416 Store Room", "floor": 4, "directions": "From the staircase, take the first right; the room is ahead."},
    {"name": "Seminar Hall", "floor": 4, "directions": "From the staircase, take the first right and walk straight; the hall is ahead."},
    {"name": "2405", "floor": 4, "directions": "From the staircase, take the first right; the room is ahead."},
    {"name": "2417 Dr Rizwan Arif", "floor": 4, "directions": "From the staircase, take the first right, then take a right turn; the cabin is on the right."},
    {"name": "2418 Dr Preeti (Faculty Room)", "floor": 4, "directions": "From the staircase, take the first right; the room is opposite 2417."},
    {"name": "2406 Department Library", "floor": 4, "directions": "From the staircase, take the first right; the library is ahead."},
    {"name": "2419 Chemical Store Room", "floor": 4, "directions": "From the staircase, take the first right and continue; the store room is ahead."},
    {"name": "2420 Mr Mahesh Arora", "floor": 4, "directions": "From the staircase, take the first right and walk straight; the room is ahead."},
    {"name": "2407", "floor": 4, "directions": "From the staircase, take the first right and walk ahead; the room is ahead."},
    {"name": "2408", "floor": 4, "directions": "From the staircase, take the first right, then take another right; the room is ahead."},
    {"name": "2409", "floor": 4, "directions": "From the staircase, take the first right, then right; the room is next to 2408."},
    {"name": "2421 Faculty Room", "floor": 4, "directions": "From the staircase, take the first right and walk straight; the room is ahead."},
    {"name": "Chemistry Lab", "floor": 4, "directions": "From the staircase, take the first right and go straight; the lab is ahead."},
    {"name": "2422", "floor": 4, "directions": "From the staircase, take the first right; the room is ahead."},
    {"name": "2423 HOD Room (Dr Sikha Gupta)", "floor": 4, "directions": "From the staircase, take the first right and walk straight; the HOD room is ahead."},
    {"name": "2410 Chemistry Lab (Ms Sunita Rao)", "floor": 4, "directions": "From the staircase, take the first right; the room is opposite 2423."},
    {"name": "2411 Dark Room 1", "floor": 4, "directions": "From the staircase, take the first right and walk straight; the room is ahead."},
    {"name": "Physics Lab 1", "floor": 4, "directions": "From the staircase, take the first right; then slight right; the lab is on the right."},
    {"name": "Physics Lab 2", "floor": 4, "directions": "From the staircase, take the first right, then take a full right turn; the lab is ahead."}
  ]
},

 {
  "name": "Architecture Block",
  "lat": 28.409562,
  "lng": 77.402890,
  "rooms": [

    /* First Floor */
    {"name": "IBM Lab", "floor": 1, "directions": "From the main staircase, take the first right; the lab is straight ahead."},
    {"name": "3107 Gender Sensitisation & Behaviour Lab", "floor": 1, "directions": "From the main staircase, take the first right, then the first left; the room is on the left."},
    {"name": "3118", "floor": 1, "directions": "From the main staircase, go right, then left; the room is opposite 3107."},
    {"name": "3117", "floor": 1, "directions": "From the main staircase, go right and continue straight; the room is on the right."},
    {"name": "Arogya Manas Lab", "floor": 1, "directions": "From the main staircase, go right and straight; the lab is opposite 3117."},
    {"name": "Mechanical, Civil & Architecture Innovation and Infra Health Lab", "floor": 1, "directions": "From the main staircase, go right and walk straight; the big lab area is ahead."},
    {"name": "3116", "floor": 1, "directions": "From the main staircase, take the first right and go straight; the room is on the right."},
    {"name": "3106", "floor": 1, "directions": "From the main staircase, take the first right and walk straight; the room is on the left."},
    {"name": "3115", "floor": 1, "directions": "From the main staircase, go right and walk straight, then take a left turn; the room is on the left."},
    {"name": "3114", "floor": 1, "directions": "From the main staircase, go right and walk straight, then take a left; the room is next to 3115."},
    {"name": "3105 Central Instrumentation Lab", "floor": 1, "directions": "From the main staircase, go right and walk straight; the room is ahead."},
    {"name": "3104", "floor": 1, "directions": "From the main staircase, go right and head straight; the room is just ahead after 3105."},
    {"name": "3113 Innovation in Education Lab", "floor": 1, "directions": "From the main staircase, go right and walk straight; the lab is opposite 3104."},
    {"name": "3112", "floor": 1, "directions": "From the main staircase, go right and continue; the room is ahead on the right."},
    {"name": "3104B", "floor": 1, "directions": "From the main staircase, go right and walk straight; the room is just ahead after 3112."},
    {"name": "3103", "floor": 1, "directions": "From the main staircase, go right and straight, then take a left turn; the room is on the left."},
    {"name": "3111 Innovation in Management Lab", "floor": 1, "directions": "From the main staircase, go right and continue straight; the lab is on the right."},
    {"name": "3103B0", "floor": 1, "directions": "From the main staircase, go right and continue ahead; the room is straight."},
    {"name": "3102", "floor": 1, "directions": "From the main staircase, go right and continue straight; the room is ahead."},
    {"name": "3110", "floor": 1, "directions": "From the main staircase, take the first right and walk straight; the room is ahead on the right."},
    {"name": "3102B", "floor": 1, "directions": "From the main staircase, go right and continue straight; the room is just ahead on the left."},
    {"name": "3109", "floor": 1, "directions": "From the main staircase, go right and straight; the room is opposite 3102B."},
    {"name": "3101B", "floor": 1, "directions": "From the main staircase, take the first right, then at the T-point take a left; the room is on the left."},
    {"name": "3101 AI, ML & Robotics Lab", "floor": 1, "directions": "From the main staircase, take the first right, then at the T-point take a right; the lab is on the right."},


    /* Second Floor */
    {"name": "3201 PCR Room", "floor": 2, "directions": "From the main staircase, take the first right; the room is directly ahead."},
    {"name": "3209", "floor": 2, "directions": "From the main staircase, take the first right and walk straight; the room is ahead."},
    {"name": "3202", "floor": 2, "directions": "From the main staircase, take the first right; the room is opposite 3209."},
    {"name": "3210 HOD Room", "floor": 2, "directions": "From the main staircase, take the first right and continue straight; the room is on the right."},
    {"name": "3203B", "floor": 2, "directions": "From the main staircase, take the first right and go straight; the room is ahead."},
    {"name": "3211 Faculty Room", "floor": 2, "directions": "From the main staircase, take the first right and continue ahead; the room is ahead."},
    {"name": "3203 Smart Classroom", "floor": 2, "directions": "From the main staircase, take the first right; the room is opposite 3211."},
    {"name": "3204", "floor": 2, "directions": "From the main staircase, take the first right and walk straight; the room is ahead."},
    {"name": "3212 Faculty Room", "floor": 2, "directions": "From the main staircase, take the first right, walk straight, then take a right turn; the room is on the right."},
    {"name": "Visual Merchandising Lab", "floor": 2, "directions": "From the main staircase, take the first right, walk straight, then take a right; the lab is opposite 3212."},
    {"name": "3213 Professor Cabin", "floor": 2, "directions": "From the main staircase, take the first right, then right; the room is next to the visual merchandise lab."},
    {"name": "3205 Studio", "floor": 2, "directions": "From the main staircase, take the first right and walk straight; the studio is ahead."},
    {"name": "3214 Assistant Professor Cabin", "floor": 2, "directions": "From the main staircase, take the first right and continue straight; the room is ahead."},
    {"name": "3215 HOD Kapil Kishor Cabin", "floor": 2, "directions": "From the main staircase, take the first right and walk straight; the cabin is just after 3214."},
    {"name": "2nd Year Studio", "floor": 2, "directions": "From the main staircase, take the first right, then the next right; the studio is straight ahead."},
    {"name": "3216 Boys Common Room", "floor": 2, "directions": "From the main staircase, take the first right, then right; the room is on the right."},
    {"name": "3206 Garment Construction Lab", "floor": 2, "directions": "From the main staircase, take the first right and go straight; the lab is ahead."},
    {"name": "3217", "floor": 2, "directions": "From the main staircase, take the first right and continue straight; the room is ahead."},
    {"name": "3218", "floor": 2, "directions": "From the main staircase, take the first right and walk straight; the room is ahead."},
    {"name": "3207 Pattern Making & Draping Lab", "floor": 2, "directions": "From the main staircase, take the first right and continue; the lab is opposite 3218."},
    {"name": "Departmental Library", "floor": 2, "directions": "From the main staircase, take the first right, then right at 3207; the library is ahead."},


    /* Third Floor */
    {"name": "3301", "floor": 3, "directions": "From the staircase, walk straight; the room is in front."},
    {"name": "3311 Art Studio", "floor": 3, "directions": "From the staircase, walk straight; the studio is next to 3301."},
    {"name": "3302 Computer Lab", "floor": 3, "directions": "From the staircase, take a right and walk straight; the lab is ahead."},
    {"name": "3312 Store Room", "floor": 3, "directions": "From the staircase, take a right, then the next right; the store is on the right."},
    {"name": "3313 Girls Common Room", "floor": 3, "directions": "From the staircase, take a right and walk straight; the room is ahead."},
    {"name": "3303 Lecture Room", "floor": 3, "directions": "From the staircase, take a right and walk straight; the room is ahead after 3313."},
    {"name": "3314 Faculty Room", "floor": 3, "directions": "From the staircase, take a right and continue; the faculty room is on the right."},
    {"name": "3304 PPT / Lecture Room", "floor": 3, "directions": "From the staircase, take a right and continue straight; the room is ahead."},
    {"name": "3315 Faculty Room", "floor": 3, "directions": "From the staircase, take a right, then take another right; the faculty room is on the right."},
    {"name": "3305", "floor": 3, "directions": "From the staircase, take a right, then right; the room is opposite 3315."},
    {"name": "3306", "floor": 3, "directions": "From the staircase, take a right and walk straight; the room is ahead."},
    {"name": "3316 Faculty Room", "floor": 3, "directions": "From the staircase, take a right and continue forward; the room is ahead."},
    {"name": "3317 Record Room", "floor": 3, "directions": "From the staircase, take a right and walk straight; the room is ahead."},
    {"name": "3318 HOD Room", "floor": 3, "directions": "From the staircase, take a right and go straight; the room is ahead."},
    {"name": "3319 Principal Room", "floor": 3, "directions": "From the staircase, take a right, walk straight, then take another right; the principal room is ahead."},
    {"name": "3307 Building Material Museum", "floor": 3, "directions": "From the staircase, take a right and go straight; the museum is ahead."},
    {"name": "3320", "floor": 3, "directions": "From the staircase, take a right and continue straight; the room is ahead."},
    {"name": "3321", "floor": 3, "directions": "From the staircase, take a right and walk straight; the room is ahead."},
    {"name": "3308 Model Making Workshop", "floor": 3, "directions": "From the staircase, take a right; the workshop is opposite 3321."},
    {"name": "3309", "floor": 3, "directions": "From the staircase, take a right and walk straight; the room is ahead."},
    {"name": "3310 Exhibition Room", "floor": 3, "directions": "From the staircase, take a right and straight; the exhibition room is next to 3309."}
  ]
},
{
  "name": "Pharmacy Block",
  "lat": 28.409942,
  "lng": 77.404573,
  "rooms": [

    /* -------------------- GROUND FLOOR (Entrance Based) -------------------- */

    {
      "name": "Machine Room",
      "floor": 0,
      "directions": "Enter the block and take the first left; the machine room is on the left side."
    },
    {
      "name": "K101 Automobile Lab 1",
      "floor": 0,
      "directions": "Enter the block and take the first right; the lab is on the right side."
    },
    {
      "name": "K105 Automobile Lab 2",
      "floor": 0,
      "directions": "From the entrance, walk straight; the lab is directly in front."
    },
    {
      "name": "K103 Sheet Metal & Welding Shop",
      "floor": 0,
      "directions": "From the entrance, walk straight; the shop is ahead on the left side."
    },
    {
      "name": "Machine Shop",
      "floor": 0,
      "directions": "From the entrance, walk straight; the machine shop is opposite the sheet metal and welding shop."
    },

    /* -------------------- FIRST FLOOR (Staircase Based) -------------------- */

    {
      "name": "K206",
      "floor": 1,
      "directions": "From the main staircase, walk straight; the room is in front."
    },
    {
      "name": "K207 Pharmaceutics Lab 3rd",
      "floor": 1,
      "directions": "From the main staircase, take the first right; the lab is on the right."
    },
    {
      "name": "K210 Pharmaceutics Lab 5th",
      "floor": 1,
      "directions": "From the main staircase, take the first right; the lab is opposite K207."
    },
    {
      "name": "K209 Microbiology Lab",
      "floor": 1,
      "directions": "From the main staircase, take the first right and walk ahead; the lab is on the right."
    },
    {
      "name": "K208 M.Pharm Pharmaceutics 2nd",
      "floor": 1,
      "directions": "From the main staircase, take the first right and walk to the end; the room is the last one on the right."
    },

    {
      "name": "K201 Dean Office",
      "floor": 1,
      "directions": "From the main staircase, take a left; the dean office is on the left."
    },
    {
      "name": "K205 Pharmacology Lab 1",
      "floor": 1,
      "directions": "From the main staircase, take a left; the lab is opposite the dean office."
    },
    {
      "name": "Computer Lab",
      "floor": 1,
      "directions": "From the main staircase, take a left and walk ahead; the computer lab is straight."
    },
    {
      "name": "K204",
      "floor": 1,
      "directions": "From the main staircase, take a left and walk ahead; the room is ahead."
    },
    {
      "name": "K202 Computer Lab",
      "floor": 1,
      "directions": "From the main staircase, take a left and walk straight; the lab is opposite K204."
    },
    {
      "name": "K203 Classroom",
      "floor": 1,
      "directions": "From the main staircase, take a left and go straight; the classroom is ahead."
    },

    /* -------------------- SECOND FLOOR -------------------- */

    {
      "name": "K308",
      "floor": 2,
      "directions": "From the main staircase, walk straight; the room is in front."
    },
    {
      "name": "K309 Classroom",
      "floor": 2,
      "directions": "From the main staircase, take the first right; the classroom is on the right."
    },
    {
      "name": "K315 Faculty Room",
      "floor": 2,
      "directions": "From the main staircase, take the first right; the faculty room is opposite K309."
    },
    {
      "name": "K314",
      "floor": 2,
      "directions": "From the main staircase, take the first right and walk straight; the room is ahead."
    },
    {
      "name": "K310",
      "floor": 2,
      "directions": "From the main staircase, take the first right and walk straight; the room is opposite K314."
    },
    {
      "name": "K313 Pharmaceutical Analysis Lab",
      "floor": 2,
      "directions": "From the main staircase, take the first right; the lab is next to K310."
    },
    {
      "name": "K311 Pharmaceutics Lab 2nd",
      "floor": 2,
      "directions": "From the main staircase, take the first right and continue to the end; the lab is the last room on the right."
    },

    {
      "name": "K301 Faculty Room",
      "floor": 2,
      "directions": "From the main staircase, take a left; the faculty room is on the left."
    },
    {
      "name": "K302 Faculty Room",
      "floor": 2,
      "directions": "From the main staircase, take a left and walk straight; the faculty room is ahead."
    },
    {
      "name": "K307 Digital Classroom",
      "floor": 2,
      "directions": "From the main staircase, take a left; the digital classroom is opposite K302."
    },
    {
      "name": "K306 Classroom",
      "floor": 2,
      "directions": "From the main staircase, take a left; the classroom is ahead."
    },
    {
      "name": "K305 Seminar Hall",
      "floor": 2,
      "directions": "From the main staircase, take a left and walk straight; the seminar hall is at the end."
    },

    /* -------------------- THIRD FLOOR -------------------- */

    {
      "name": "K408 Chemical Store Room",
      "floor": 3,
      "directions": "From the staircase, walk straight; the store room is in front."
    },
    {
      "name": "K409 Classroom",
      "floor": 3,
      "directions": "From the staircase, take the first right; the classroom is on the right."
    },
    {
      "name": "K413 Pharmaceutical Chemistry Lab 1",
      "floor": 3,
      "directions": "From the staircase, take the first right and walk straight; the lab is ahead."
    },
    {
      "name": "K410 Classroom",
      "floor": 3,
      "directions": "From the staircase, walk right and continue straight; the classroom is ahead."
    },
    {
      "name": "K411 Pharmacognosy Lab 1",
      "floor": 3,
      "directions": "From the staircase, walk right and continue; the lab is next to K410."
    },
    {
      "name": "K142 Pharmacognosy Lab 2nd",
      "floor": 3,
      "directions": "From the staircase, walk right until the end; the lab is the last room on the right."
    },

    {
      "name": "K407 Pharmacology 3rd",
      "floor": 3,
      "directions": "From the staircase, take a left; the room is on the left side."
    },
    {
      "name": "K401 Pharmaceutical Chemistry Lab 2nd",
      "floor": 3,
      "directions": "From the staircase, take a left and walk straight; the lab is ahead."
    },
    {
      "name": "K402 Pharmaceutical Chemistry Lab 3rd",
      "floor": 3,
      "directions": "From the staircase, take a left and continue; the lab is ahead on the right."
    },
    {
      "name": "K406 Classroom",
      "floor": 3,
      "directions": "From the staircase, take a left; the classroom is opposite K402."
    },
    {
      "name": "K405 Classroom",
      "floor": 3,
      "directions": "From the staircase, take a left and continue straight; the classroom is ahead."
    },
    {
      "name": "K403 Pharmaceutics Lab 4",
      "floor": 3,
      "directions": "From the staircase, take a left and walk ahead; the lab is near K405."
    },
    {
      "name": "K404 Store Room",
      "floor": 3,
      "directions": "From the staircase, take a left and walk straight; the store room is at the end."
    },

    /* -------------------- FOURTH FLOOR -------------------- */

    {
      "name": "K506",
      "floor": 4,
      "directions": "From the staircase, walk straight; the room is in front."
    },
    {
      "name": "K513",
      "floor": 4,
      "directions": "From the staircase, take the first right; the room is on the right."
    },
    {
      "name": "K507 Classroom",
      "floor": 4,
      "directions": "From the staircase, take the first right and walk ahead; the classroom is on the right."
    },
    {
      "name": "K512 Pharmacy Practice",
      "floor": 4,
      "directions": "From the staircase, take the first right; the room is opposite K507."
    },
    {
      "name": "K508 Classroom",
      "floor": 4,
      "directions": "From the staircase, take the first right and walk straight; the classroom is ahead."
    },
    {
      "name": "K509 Classroom",
      "floor": 4,
      "directions": "From the staircase, take the first right; the classroom is ahead on the right."
    },
    {
      "name": "K511",
      "floor": 4,
      "directions": "From the staircase, take the first right; the room is opposite K509."
    },

    {
      "name": "K501 Faculty Room",
      "floor": 4,
      "directions": "From the staircase, take a left; the faculty room is on the left side."
    },
    {
      "name": "K505 Pharmacology Lab 2nd",
      "floor": 4,
      "directions": "From the staircase, take a left; the lab is opposite K501."
    },
    {
      "name": "K502 Pharmaceutics PG Lab 1",
      "floor": 4,
      "directions": "From the staircase, take a left and walk ahead; the lab is on the left."
    },
    {
      "name": "K504 Pharmaceutics Lab 1",
      "floor": 4,
      "directions": "From the staircase, take a left; the lab is opposite K502."
    },
    {
      "name": "K503 Classroom",
      "floor": 4,
      "directions": "From the staircase, take a left and walk straight; the classroom is ahead."
    }

  ]
},

  {
  "name": "Central Block",
  "lat": 28.409284,
  "lng": 77.403772,
  "rooms": [
    {
      "name": "E120",
      "floor": 0,
      "directions": "From the main entrance, go inside and take an immediate left. The first room is E120."
    },
    {
      "name": "E119 Alumni Cell",
      "floor": 0,
      "directions": "From the main entrance, take a left and walk straight ahead. After E120, you will find E119 Alumni Cell."
    },
    {
      "name": "S105",
      "floor": 0,
      "directions": "From the main entrance, take a left and walk straight. After E119, you will reach room S105."
    },
    {
      "name": "S107",
      "floor": 0,
      "directions": "From the main entrance, take a left and reach S105. From there, take a right and walk straight to reach S107."
    },
    {
      "name": "S117",
      "floor": 0,
      "directions": "From the main entrance, go to S107. The room S117 is located directly opposite S107."
    },
    {
      "name": "S108 Material Testing Lab",
      "floor": 0,
      "directions": "From the main entrance, go left, then right from S105, and walk straight. You will find S108 Material Testing Lab."
    },
    {
      "name": "S116",
      "floor": 0,
      "directions": "From the main entrance, go to S108. The room S116 is located directly opposite it."
    },
    {
      "name": "S115",
      "floor": 0,
      "directions": "From the main entrance, turn left and proceed straight after taking right from S105. You will find S115."
    },
    {
      "name": "S114",
      "floor": 0,
      "directions": "From the main entrance, continue forward past S115. The next room is S114."
    },
    {
      "name": "Central Library",
      "floor": 0,
      "directions": "From the main entrance, turn right. Walk straight and take another right turn. Walk straight to reach the Central Library."
    },
    {
      "name": "Quad Area",
      "floor": 0,
      "directions": "From the main entrance, go towards the Central Library. After the library, turn right and walk ahead to reach the large Quad Area."
    },
    {
      "name": "N133",
      "floor": 0,
      "directions": "From the main entrance, pass the Central Library and Quad Area. N133 is located straight ahead."
    },
    {
      "name": "N134 Transport Engineering Lab",
      "floor": 0,
      "directions": "From the main entrance, go past the Central Library and Quad Area, then take a right to reach N134 Transport Engineering Lab."
    },
    {
      "name": "N129",
      "floor": 0,
      "directions": "From the main entrance, go past the Quad Area and walk straight to reach room N129."
    },
    {
      "name": "Central Block Back Gate",
      "floor": 0,
      "directions": "From the main entrance, go towards the Quad Area. Near room N129, on the left side, you will find the Central Block Back Gate."
    },
    {
      "name": "N135 Administration",
      "floor": 0,
      "directions": "From the main entrance, go towards the Quad Area. From the back gate area, take a right and walk straight to reach N135 Administration."
    },
    {
      "name": "N136 Academic Section",
      "floor": 0,
      "directions": "From the main entrance, continue straight after N135 to reach N136 Academic Section."
    },
    {
      "name": "N128",
      "floor": 0,
      "directions": "From the main entrance, go to N136. The room N128 is located directly opposite."
    },
    {
      "name": "N127",
      "floor": 0,
      "directions": "From the main entrance, walk ahead past N128 to reach N127."
    },
    {
      "name": "Accounts Section",
      "floor": 0,
      "directions": "From the main entrance, go past N127. On the left-hand side, you will find the Accounts Section."
    },
    {
      "name": "N137 Seminar Hall",
      "floor": 0,
      "directions": "From the main entrance, enter and take a left. Walk straight to find N137 Seminar Hall near the Accounts Section."
    },
    {
      "name": "E125",
      "floor": 0,
      "directions": "From the main entrance, go left towards N137, then take a right and walk straight to reach E125."
    },
    {
      "name": "E101",
      "floor": 0,
      "directions": "From the main entrance, go left from the entrance and walk straight to reach E101."
    },
    {
      "name": "E124 Associate Professor",
      "floor": 0,
      "directions": "From the main entrance, go to E101. The room E124 is directly opposite E101."
    },
    {
      "name": "E123 Center of Legal Education",
      "floor": 0,
      "directions": "From the main entrance, walk past E101. You will reach E123 Center of Legal Education."
    },
    {
      "name": "E102",
      "floor": 0,
      "directions": "From the main entrance, go to E123. Room E102 is located directly opposite."
    },
    {
      "name": "E122",
      "floor": 0,
      "directions": "From the main entrance, walk further ahead past E123 to reach E122."
    },
    {
      "name": "Back Gate to Quad Route",
      "floor": 0,
      "directions": "From the back gate, enter the building, turn right, then turn left and walk straight to reach the Quad Area. From there, the Central Library is ahead."
    },
    {
      "name": "Back Gate to Accounts",
      "floor": 0,
      "directions": "From the back gate, enter the building and turn left. Walk straight to reach the Accounts Section."
    },
    {
      "name": "Stairs to Second Floor",
      "floor": 0,
      "directions": "After entering through the back gate, the stairs to the second floor are located inside the building."
    },
    {
      "name": "Internal Quality Assurance Cell (IQAC)",
      "floor": 1,
      "directions": "From the staircase, go straight and take the left path. You will reach the Internal Quality Assurance Cell (IQAC)."
    },
    {
      "name": "E202",
      "floor": 1,
      "directions": "From the staircase, take the left path and walk inside. After IQAC, you will find room E202."
    },
    {
      "name": "E221 Dean Academics",
      "floor": 1,
      "directions": "From the staircase, take the left path and walk straight ahead. After E202, you will reach E221 Dean Academics."
    },
    {
      "name": "Branding and Marketing",
      "floor": 1,
      "directions": "From the staircase, go left and walk ahead. After E221, you will reach the Branding and Marketing office."
    },
    {
      "name": "E222 Associate Dean Academics",
      "floor": 1,
      "directions": "From the staircase, go left and walk ahead. After the Branding and Marketing office, you will reach E222 Associate Dean Academics."
    },
    {
      "name": "N236 Seminar Hall 3",
      "floor": 1,
      "directions": "From the staircase, go left and walk straight. You will see N236 Seminar Hall 3 in front of you."
    },
    {
      "name": "N223",
      "floor": 1,
      "directions": "From the staircase, return to the junction and take the right path. Walk straight to reach room N223."
    },
    {
      "name": "N224",
      "floor": 1,
      "directions": "From the staircase, take the right path and walk ahead. After N223, you will reach N224."
    },
    {
      "name": "N235",
      "floor": 1,
      "directions": "From the staircase, go right towards N224. The room N235 is located directly opposite."
    },
    {
      "name": "N225",
      "floor": 1,
      "directions": "From the staircase, take the right path and walk forward. After N224, you will reach N225."
    },
    {
      "name": "N234 Training and Placement Cell",
      "floor": 1,
      "directions": "From the staircase, take the right path and continue walking. After N225, you will reach N234 Training and Placement Cell. Third floor stairs are located nearby."
    },
    {
      "name": "N233 Medical Room",
      "floor": 1,
      "directions": "From the staircase, go right and walk straight past N234. You will reach N233 Medical Room."
    },
    {
      "name": "N266",
      "floor": 1,
      "directions": "From the staircase, take the right path and walk straight. After N233, you will reach N266."
    },
    {
      "name": "N232",
      "floor": 1,
      "directions": "From the staircase, go right and continue straight. After N266, you will find room N232. A right turn from here leads to the Auditorium."
    },
    {
      "name": "Auditorium",
      "floor": 1,
      "directions": "From the staircase, go right and reach N232. From N232, take a right turn and walk to reach the Auditorium."
    },
    {
      "name": "N231",
      "floor": 1,
      "directions": "From the staircase, take the right path and walk straight past N232. You will reach room N231."
    },
    {
      "name": "N227",
      "floor": 1,
      "directions": "From the staircase, continue right side and walk ahead. After N231, reach N227."
    },
    {
      "name": "N230",
      "floor": 1,
      "directions": "From the staircase, go right and reach N227. N230 is located directly opposite N227."
    },
    {
      "name": "N228",
      "floor": 1,
      "directions": "From the staircase, go right and continue forward. After N227, you will reach N228."
    },
    {
      "name": "N229",
      "floor": 1,
      "directions": "From the staircase, go right and walk to the end of the corridor. The last room on this side is N229."
    },
    {
      "name": "E220 Chief Operating Officer",
      "floor": 1,
      "directions": "From the staircase, go to the right side corridor. E220 Chief Operating Officer is located here."
    },
    {
      "name": "E203 Conference Hall",
      "floor": 1,
      "directions": "From the staircase, go right and walk straight. You will reach E203 Conference Hall."
    },
    {
      "name": "E204",
      "floor": 1,
      "directions": "From the staircase, continue right side and walk ahead. After E203, you will reach E204."
    },
    {
      "name": "E219",
      "floor": 1,
      "directions": "From the staircase, go right near E204. E219 is located opposite E204."
    },
    {
      "name": "E218 Director",
      "floor": 1,
      "directions": "From the staircase, go right and continue ahead. After E204, you will reach E218 Director."
    },
    {
      "name": "Register Office",
      "floor": 1,
      "directions": "From the staircase, go right and walk ahead. After E218, you will reach the Register Office."
    },
    {
      "name": "E205 Seminar Hall",
      "floor": 1,
      "directions": "From the staircase, go right and continue forward. After Register Office, you will reach E205 Seminar Hall."
    },
    {
      "name": "E206 Pro Vice Chancellor",
      "floor": 1,
      "directions": "From the staircase, take a left turn and walk straight. You will directly reach E206 Pro Vice Chancellor."
    },
    {
      "name": "E207 PVC Room",
      "floor": 1,
      "directions": "From the staircase, go left to E206, then take a right and walk ahead. You will reach E207 PVC Room."
    },
    {
      "name": "E217",
      "floor": 1,
      "directions": "From the staircase, go to the right of E207. E217 is located opposite it."
    },
    {
      "name": "E216A",
      "floor": 1,
      "directions": "From the staircase, go right and continue straight. You will reach E216A."
    },
    {
      "name": "E216",
      "floor": 1,
      "directions": "From the staircase, go right and walk further ahead. You will reach room E216."
    },
    {
      "name": "E215",
      "floor": 1,
      "directions": "From the staircase, go right and continue walking. After E216, you will reach E215."
    },
    {
      "name": "E208 Dining Room",
      "floor": 1,
      "directions": "From the staircase, keep walking on the right side corridor. You will reach E208 Dining Room."
    },
    {
      "name": "Pantry",
      "floor": 1,
      "directions": "From the staircase, continue past the dining room. You will find the Pantry."
    },
    {
      "name": "E209 Vice Chancellor Room",
      "floor": 1,
      "directions": "From the staircase, go right and walk deep inside the corridor. You will reach E209 Vice Chancellor Room."
    },
    {
      "name": "E210 Board Room",
      "floor": 1,
      "directions": "From the staircase, go right and continue walking. After E209, you will reach E210 Board Room."
    },
    {
      "name": "Chancellor Office",
      "floor": 1,
      "directions": "From the staircase, go right till E210. In front, you will find the Chancellor Office."
    },
    {
      "name": "E211 Chancellor",
      "floor": 1,
      "directions": "From the staircase, go right and enter the Chancellor Office area. Inside, you will find room E211 Chancellor."
    },


    {
      "name": "E303 Lecture Hall 1",
      "floor": 2,
      "directions": "From the staircase, take the left corridor. Walk ahead to reach E303 Lecture Hall 1."
    },
    {
      "name": "E302 Gurukul Kakshyay 1",
      "floor": 2,
      "directions": "From the staircase, go left and continue straight. After E303, you will reach E302 Gurukul Kakshyay 1."
    },
    {
      "name": "N332 Faculty Room",
      "floor": 2,
      "directions": "From the staircase, go left towards E302. The room N332 Faculty Room is located opposite."
    },
    {
      "name": "E301 Discussion Room",
      "floor": 2,
      "directions": "From the staircase, take the left corridor and walk forward. After E302, you will reach E301 Discussion Room."
    },
    {
      "name": "E323 Faculty Room",
      "floor": 2,
      "directions": "From the staircase, go left and reach E301. The room E323 Faculty Room is opposite."
    },
    {
      "name": "E324 HOD MBA Office",
      "floor": 2,
      "directions": "From the staircase, go left and walk ahead. After E301, you will reach E324 HOD MBA Office."
    },
    {
      "name": "N338",
      "floor": 2,
      "directions": "From the staircase, continue left corridor past E324 to reach N338."
    },
    {
      "name": "N337 Seminar Hall 2",
      "floor": 2,
      "directions": "From the staircase, go left and walk ahead near N338. N337 Seminar Hall 2 is nearby."
    },
    {
      "name": "N325",
      "floor": 2,
      "directions": "From the staircase, return to the junction and take the right corridor. Walk straight to reach N325."
    },
    {
      "name": "N326 Research Wing",
      "floor": 2,
      "directions": "From the staircase, take the right corridor and walk ahead. After N325, you will reach N326 Research Wing."
    },
    {
      "name": "N336 Lecture Hall 4",
      "floor": 2,
      "directions": "From the staircase, go right and reach N326. The room N336 Lecture Hall 4 is located opposite."
    },
    {
      "name": "N335 Lecture Hall 3",
      "floor": 2,
      "directions": "From the staircase, go right and walk ahead. After N336, you will reach N335 Lecture Hall 3."
    },
    {
      "name": "N327 Faculty Room",
      "floor": 2,
      "directions": "From the staircase, go right corridor and continue walking. You will reach N327 Faculty Room."
    },
    {
      "name": "N328",
      "floor": 2,
      "directions": "From the staircase, walk straight on the right corridor. After N327, you will find N328."
    },
    {
      "name": "N334 Lecture Hall 2",
      "floor": 2,
      "directions": "From the staircase, continue forward on the right corridor. You will reach N334 Lecture Hall 2."
    },
    {
      "name": "N333 Leadership Hall 2",
      "floor": 2,
      "directions": "From the staircase, walk further ahead on the right corridor. You will reach N333 Leadership Hall 2."
    },
    {
      "name": "Auditorium Balcony",
      "floor": 2,
      "directions": "From the staircase, go left side near N333. The upper balcony of the auditorium is located here."
    },
    {
      "name": "N332",
      "floor": 2,
      "directions": "From the staircase, go towards the left-side balcony area and continue walking. You will reach N332."
    },
    {
      "name": "N329",
      "floor": 2,
      "directions": "From the staircase, go left towards the balcony side and move ahead. After N332, you will reach N329."
    },
    {
      "name": "N331 Gurukul Kakshyay 3",
      "floor": 2,
      "directions": "From the staircase, go left side balcony corridor. After N329, you will reach N331 Gurukul Kakshyay 3."
    },
    {
      "name": "N330",
      "floor": 2,
      "directions": "From the staircase, follow the left balcony corridor. N330 is located opposite N331."
    },
    {
      "name": "E304 Synergy Suite",
      "floor": 2,
      "directions": "From the staircase, take the right corridor. After E303, you will reach E304 Synergy Suite."
    },
    {
      "name": "E321 Faculty Room",
      "floor": 2,
      "directions": "From the staircase, go right and walk straight. After E304, you will reach E321 Faculty Room."
    },
    {
      "name": "E320 Faculty Room",
      "floor": 2,
      "directions": "From the staircase, continue right corridor ahead. After E321, you will reach E320 Faculty Room."
    },
    {
      "name": "E305 Discovery Hall",
      "floor": 2,
      "directions": "From the staircase, go right and reach E320. The room E305 Discovery Hall is located opposite."
    },
    {
      "name": "E306 Tutorial Hall 1",
      "floor": 2,
      "directions": "From the staircase, walk further along the right corridor. You will reach E306 Tutorial Hall 1."
    },
    {
      "name": "S307 Seminar Hall 1",
      "floor": 2,
      "directions": "From the staircase, go right and walk ahead. After E306, you will reach S307 Seminar Hall 1."
    },
    {
      "name": "Library",
      "floor": 2,
      "directions": "From the staircase, go right side corridor. The Library is located near S307."
    },
    {
      "name": "S309 Tutorial Hall 2",
      "floor": 2,
      "directions": "From the staircase, take a right turn near the library. You will reach S309 Tutorial Hall 2."
    },
    {
      "name": "S319 Professor Room",
      "floor": 2,
      "directions": "From the staircase, go right towards S309. The room S319 is located opposite."
    },
    {
      "name": "S318 Faculty Room",
      "floor": 2,
      "directions": "From the staircase, continue right corridor. You will reach S318 Faculty Room."
    },
    {
      "name": "S310 Gurukul Kakshyay 2",
      "floor": 2,
      "directions": "From the staircase, walk further straight to reach S310 Gurukul Kakshyay 2."
    },
    {
      "name": "S317",
      "floor": 2,
      "directions": "From the staircase, continue walking along the right corridor to reach S317."
    },
    {
      "name": "S311 Exam Conduct Room",
      "floor": 2,
      "directions": "From the staircase, go right corridor and walk straight. You will reach S311 Exam Conduct Room."
    },
    {
      "name": "S316 Store Room",
      "floor": 2,
      "directions": "From the staircase, keep going straight. After S311, you will reach S316 Store Room."
    },
    {
      "name": "S312",
      "floor": 2,
      "directions": "From the staircase, go straight to the end of the corridor. You will reach S312, near the back side of the auditorium balcony."
    },


    {
      "name": "E410",
      "floor": 3,
      "directions": "From the staircase, take the right corridor. The first room you reach is E410."
    },
    {
      "name": "E409",
      "floor": 3,
      "directions": "From the staircase, go right and walk straight past E410. You will reach E409."
    },
    {
      "name": "N427",
      "floor": 3,
      "directions": "From the staircase, go right past E410. N427 is located opposite E409."
    },
    {
      "name": "E406",
      "floor": 3,
      "directions": "From the staircase, go right past E409. You will reach E406."
    },
    {
      "name": "N428 Faculty Room - Department of English",
      "floor": 3,
      "directions": "From the staircase, go right past E406. N428 Faculty Room is located opposite E406."
    },
    {
      "name": "S406",
      "floor": 3,
      "directions": "From the staircase, go right past E406 and take the next right, then left. You will reach S406."
    },
    {
      "name": "S405",
      "floor": 3,
      "directions": "From the staircase, follow the same path as S406. S405 is located nearby."
    },
    {
      "name": "S429 Library SoHSS",
      "floor": 3,
      "directions": "From the staircase, take a right then another right after S405. You will reach S429 Library SoHSS."
    },
    {
      "name": "S430 Faculty Room",
      "floor": 3,
      "directions": "From the staircase, go right and continue past S429. S430 Faculty Room is located opposite S404 Classroom."
    },
    {
      "name": "S404 Classroom",
      "floor": 3,
      "directions": "From the staircase, go right and walk straight past S429. S404 Classroom is opposite S430."
    },
    {
      "name": "S403",
      "floor": 3,
      "directions": "From the staircase, go right and continue ahead. After S404, you will reach S403."
    },
    {
      "name": "S431 HOD Room",
      "floor": 3,
      "directions": "From the staircase, continue right corridor past S403 to reach S431 HOD Room."
    },
    {
      "name": "S402 Social Science Lab",
      "floor": 3,
      "directions": "From the staircase, go right and continue straight. You will reach S402 Social Science Lab."
    },
    {
      "name": "S402 Science Lab",
      "floor": 3,
      "directions": "From the staircase, go right past Social Science Lab. You will reach S402 Science Lab."
    },
    {
      "name": "S432 Associate Professor",
      "floor": 3,
      "directions": "From the staircase, go right and continue straight past Science Lab. You will reach S432 Associate Professor."
    },
    {
      "name": "S401 Ms Minakshi Breja",
      "floor": 3,
      "directions": "From the staircase, go right corridor past S432. S401 Ms Minakshi Breja is located opposite."
    },
    {
      "name": "S433",
      "floor": 3,
      "directions": "From the staircase, go right and continue straight. After S432, you will reach S433, marking the end of the right side corridor."
    },
    {
      "name": "E411 BA(H) Psychology Classroom",
      "floor": 3,
      "directions": "From the staircase, take the left corridor. The first room is E411 BA(H) Psychology Classroom."
    },
    {
      "name": "N426 Head Department of English (Chief Protector)",
      "floor": 3,
      "directions": "From the staircase, go left past E411. N426 is located opposite E411."
    },
    {
      "name": "N425 Audio Video Section",
      "floor": 3,
      "directions": "From the staircase, take the left corridor and walk past N426. The room N425 Audio Video Section is nearby."
    },
    {
      "name": "E412 BA(H) Psychology Classroom",
      "floor": 3,
      "directions": "From the staircase, go left corridor. After N425, you will reach E412 BA(H) Psychology Classroom."
    },
    {
      "name": "N413 Seminar Hall",
      "floor": 3,
      "directions": "From the staircase, go left and walk straight. N413 Seminar Hall is located opposite E412."
    },
    {
      "name": "N424 Faculty Room",
      "floor": 3,
      "directions": "From the staircase, take the left corridor. N424 Faculty Room is on the left side."
    },
    {
      "name": "N414 Gyatra (Psychology Lab)",
      "floor": 3,
      "directions": "From the staircase, go left corridor past N424. You will reach N414 Gyatra (Psychology Lab) opposite."
    },
    {
      "name": "N415 BA(H) Psychology",
      "floor": 3,
      "directions": "From the staircase, continue left corridor. N415 BA(H) Psychology is located nearby N414."
    },
    {
      "name": "N423 Faculty Room - Department of Psychology",
      "floor": 3,
      "directions": "From the staircase, go left corridor and walk straight. You will reach N423 Faculty Room."
    },
    {
      "name": "Department of English",
      "floor": 3,
      "directions": "From the staircase, continue straight corridor on the left side to reach the Department of English area."
    },
    {
      "name": "N422 Bodhi",
      "floor": 3,
      "directions": "From the staircase, walk straight past Department of English. You will reach N422 Bodhi and nearby N421."
    },
    {
      "name": "N421",
      "floor": 3,
      "directions": "From the staircase, continue straight. N421 is located next to N422 Bodhi."
    },
    {
      "name": "N416 BA(H) Psychology",
      "floor": 3,
      "directions": "From the staircase, go straight corridor past N422. You will reach N416 BA(H) Psychology."
    },
    {
      "name": "N41U BA(H) Psychology",
      "floor": 3,
      "directions": "From the staircase, continue straight. N41U BA(H) Psychology is located next to N416."
    },
    {
      "name": "N418 BA(H) Psychology",
      "floor": 3,
      "directions": "From the staircase, go straight corridor. You will reach N418 BA(H) Psychology."
    },
    {
      "name": "N420 Housekeeping",
      "floor": 3,
      "directions": "From the staircase, walk straight past N418. N420 Housekeeping is located opposite."
    },
    {
      "name": "N419 Classroom",
      "floor": 3,
      "directions": "From the staircase, continue straight corridor past N420. You will reach N419 Classroom."
    },



    {
      "name": "E510",
      "floor": 4,
      "directions": "From the staircase, take the right corridor. The first room is E510."
    },
    {
      "name": "E529",
      "floor": 4,
      "directions": "From the staircase, go right past E510 and continue straight to reach E529."
    },
    {
      "name": "E530 Faculty Room",
      "floor": 4,
      "directions": "From the staircase, go right and walk past E529. You will reach E530 Faculty Room."
    },
    {
      "name": "E509",
      "floor": 4,
      "directions": "From the staircase, go right past E530. E509 is located opposite E530."
    },
    {
      "name": "E508",
      "floor": 4,
      "directions": "From the staircase, go right past E509 and continue straight. You will reach E508."
    },
    {
      "name": "E531 Faculty Room",
      "floor": 4,
      "directions": "From the staircase, go right past E508. You will reach E531 Faculty Room."
    },
    {
      "name": "S507 Library - School of Law",
      "floor": 4,
      "directions": "From the staircase, go right corridor and walk straight past E531. S507 Library is located here."
    },
    {
      "name": "S506",
      "floor": 4,
      "directions": "From the staircase, go right past the Library. S506 is nearby."
    },
    {
      "name": "S532 Faculty Room",
      "floor": 4,
      "directions": "From the staircase, take a right near S506 and continue. S532 Faculty Room is located along this corridor."
    },
    {
      "name": "S533 Faculty Room",
      "floor": 4,
      "directions": "From the staircase, go right past S532. S533 Faculty Room is located opposite S505."
    },
    {
      "name": "S505",
      "floor": 4,
      "directions": "From the staircase, go right past S533. S505 is located opposite."
    },
    {
      "name": "S504",
      "floor": 4,
      "directions": "From the staircase, continue right corridor past S505. You will reach S504."
    },
    {
      "name": "S534",
      "floor": 4,
      "directions": "From the staircase, walk straight along the right corridor past S504. You will reach S534."
    },
    {
      "name": "S503",
      "floor": 4,
      "directions": "From the staircase, continue straight along the right corridor. You will reach S503."
    },
    {
      "name": "S535",
      "floor": 4,
      "directions": "From the staircase, walk straight past S503. You will reach S535."
    },
    {
      "name": "S502",
      "floor": 4,
      "directions": "From the staircase, continue straight past S535. You will reach S502."
    },
    {
      "name": "S501",
      "floor": 4,
      "directions": "From the staircase, walk straight to the end of the right corridor. S501 marks the end."
    },
    {
      "name": "E528 Faculty Room",
      "floor": 4,
      "directions": "From the staircase, take the left corridor. The first room on the left is E528 Faculty Room."
    },
    {
      "name": "E511 Classroom",
      "floor": 4,
      "directions": "From the staircase, go left and walk straight. E511 Classroom is located opposite E528."
    },
    {
      "name": "E512 Classroom",
      "floor": 4,
      "directions": "From the staircase, continue straight on the left corridor. After E511, you will reach E512 Classroom."
    },
    {
      "name": "E527 Computer Lab",
      "floor": 4,
      "directions": "From the staircase, go straight left corridor past E512. E527 Computer Lab is opposite."
    },
    {
      "name": "E526 HOD Room",
      "floor": 4,
      "directions": "From the staircase, continue left corridor past E527. You will reach E526 HOD Room."
    },
    {
      "name": "Moot Court Room 513",
      "floor": 4,
      "directions": "From the staircase, go straight along left corridor. After E526, you will reach Moot Court Room 513."
    },
    {
      "name": "N525 Faculty Room",
      "floor": 4,
      "directions": "From the staircase, continue straight on left corridor. You will reach N525 Faculty Room."
    },
    {
      "name": "N524 Faculty Room",
      "floor": 4,
      "directions": "From the staircase, walk straight past N525. You will reach N524 Faculty Room."
    },
    {
      "name": "N514 Classroom",
      "floor": 4,
      "directions": "From the staircase, continue left corridor. N514 Classroom is located opposite N524."
    },
    {
      "name": "N515 Classroom",
      "floor": 4,
      "directions": "From the staircase, go straight past N514. You will reach N515 Classroom."
    },
    {
      "name": "Research and Development Cell",
      "floor": 4,
      "directions": "From the staircase, continue straight corridor. After N515, you will reach Research and Development Cell."
    },
    {
      "name": "N522 Classroom",
      "floor": 4,
      "directions": "From the staircase, go straight past the Research and Development Cell. You will reach N522 Classroom."
    },
    {
      "name": "N516",
      "floor": 4,
      "directions": "From the staircase, continue straight past N522. N516 is located opposite."
    },
    {
      "name": "N517",
      "floor": 4,
      "directions": "From the staircase, continue straight corridor. N517 is adjacent to N516."
    },
    {
      "name": "N518 Classroom",
      "floor": 4,
      "directions": "From the staircase, walk straight past N517. You will reach N518 Classroom."
    },
    {
      "name": "N521",
      "floor": 4,
      "directions": "From the staircase, go straight past N518 Classroom. N521 is located opposite."
    },
    {
      "name": "N520 Faculty Room",
      "floor": 4,
      "directions": "From the staircase, continue straight corridor past N521. You will reach N520 Faculty Room."
    },
    {
      "name": "N519 Classroom",
      "floor": 4,
      "directions": "From the staircase, continue straight. N519 Classroom is located opposite N520."
    }





    
  ]
},

    {
      "name": "Girls Hostel",
      "rooms": [
      ]
    },
    {
      "name": "Library",
      "rooms": [
        {"name": "Library(Central Block)", "floor": 0, "directions": "From the main entrance, turn right. Walk straight and take another right turn. Walk straight to reach the Central Library."},
      ]
    },
    {
      "name": "Canteen",
      "rooms": [
      ]
    },
        {
      "name": "Music and Dance",
      "lat": 28.408769,
      "lng": 77.402810,
      "rooms": []
    },
  ];

  String? selectedBlock;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
  selectedBlock == null ? "Campus Blocks" : selectedBlock!,
  style: const TextStyle(color: Colors.white),
),
        backgroundColor: const Color(0xFF0F2027),
        leading: selectedBlock != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    selectedBlock = null;
                  });
                },
              )
            : null,
      ),
      backgroundColor: const Color(0xFF0F2027),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: selectedBlock == null ? _buildBlockList() : _buildRoomList(),
        ),
      ),
    );
  }

  Widget _buildBlockList() {
  return ListView.builder(
    itemCount: _blocks.length,
    itemBuilder: (context, index) {
      final block = _blocks[index];

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.deepPurpleAccent.withOpacity(0.4),
            width: 1.3,
          ),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.05),
              Colors.white.withOpacity(0.02)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurpleAccent.withOpacity(0.25),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),

          leading: const Icon(Icons.apartment,
              color: Colors.deepPurpleAccent, size: 30),

          title: Text(
            block['name'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          trailing: const Icon(Icons.arrow_forward_ios,
              color: Colors.white70, size: 18),

          onTap: () {
            setState(() {
              selectedBlock = block['name'];
            });
          },
        ),
      );
    },
  );
}


  Widget _buildRoomList() {
  final block = _blocks.firstWhere((b) => b['name'] == selectedBlock);

  final rooms = (block['rooms'] as List<dynamic>).where((room) {
    final name = room['name'].toString().toLowerCase();
    return name.contains(searchQuery);
  }).toList();

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: TextField(
          controller: searchController,
          onChanged: (value) {
            setState(() {
              searchQuery = value.toLowerCase();
            });
          },
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search room...",
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white12,
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),

      Expanded(
        child: ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.blueAccent.withOpacity(0.4),
                  width: 1.2,
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.04),
                    Colors.white.withOpacity(0.015)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.25),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: ListTile(
                leading: const Icon(Icons.meeting_room,
                    color: Colors.blueAccent, size: 28),
                title: Text(
                  room['name'],
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                subtitle: Text(
                  "Floor ${room['floor']}",
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: const Icon(Icons.info_outline, color: Colors.white70),
                onTap: () => _showRoomDetails(room),
              ),
            );
          },
        ),
      ),
    ],
  );
}

  void _showRoomDetails(Map<String, dynamic> room) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 5,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                room['name'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 10),
              Text("Floor: ${room['floor']}",
                  style: const TextStyle(fontSize: 16, color: Color.fromARGB(221, 255, 255, 255))),
              const SizedBox(height: 8),
              Text(
                "Directions: ${room['directions']}",
                style: const TextStyle(fontSize: 15, color: Color.fromARGB(255, 255, 255, 255)),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Got it"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
