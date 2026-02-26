import 'package:flutter/material.dart';
import 'language_service.dart';

/// Central place for all translated strings in the app.
/// Usage: AppLocalizations.of(context).loginTitle
class AppLocalizations {
  final AppLanguage language;

  AppLocalizations(this.language);

  /// Convenience accessor from any widget
  static AppLocalizations of(BuildContext context) {
    final service = LanguageServiceProvider.of(context);
    return AppLocalizations(service.currentLanguage);
  }

  // ─── Mapping helper ─────────────────────────────────────────────────
  String _t(String en, String ms, String zh) {
    switch (language) {
      case AppLanguage.english:
        return en;
      case AppLanguage.malay:
        return ms;
      case AppLanguage.chinese:
        return zh;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  APP GENERAL
  // ═══════════════════════════════════════════════════════════════════════
  String get appTitle => _t('Kita Agro', 'Kita Agro', 'Kita Agro');

  // ═══════════════════════════════════════════════════════════════════════
  //  WELCOME SCREEN
  // ═══════════════════════════════════════════════════════════════════════
  String get welcomeTitle => _t(
    'Welcome to Kita Agro',
    'Selamat Datang ke Kita Agro',
    '欢迎使用 Kita Agro',
  );
  String get welcomeSubtitle => _t(
    'Empowering the next generation of farmers and agropreneurs.',
    'Memperkasakan generasi petani dan agropreneur seterusnya.',
    '赋能新一代农民和农业企业家。',
  );
  String get getStarted => _t('Get Started', 'Mula', '开始');

  // ═══════════════════════════════════════════════════════════════════════
  //  LOGIN SCREEN
  // ═══════════════════════════════════════════════════════════════════════
  String get loginTitle => _t('Kita Agro', 'Kita Agro', 'Kita Agro');
  String get email => _t('Email', 'Emel', '电子邮件');
  String get password => _t('Password', 'Kata Laluan', '密码');
  String get login => _t('Login', 'Log Masuk', '登录');
  String get signInWithGoogle =>
      _t('Sign in with Google', 'Log masuk dengan Google', '使用 Google 登录');
  String get dontHaveAccount =>
      _t("Don't have an account?", 'Belum mempunyai akaun?', '还没有账户?');
  String get register => _t('Register', 'Daftar', '注册');
  String get emailAndPasswordRequired => _t(
    'Please enter both email and password.',
    'Sila masukkan emel dan kata laluan.',
    '请输入电子邮件和密码。',
  );
  String get googleSignInFailed => _t(
    'Google Sign In failed or canceled.',
    'Log masuk Google gagal atau dibatalkan.',
    'Google 登录失败或已取消。',
  );
  String get selectLanguage => _t('Select Language', 'Pilih Bahasa', '选择语言');

  // ═══════════════════════════════════════════════════════════════════════
  //  REGISTER SCREEN
  // ═══════════════════════════════════════════════════════════════════════
  String get createAccount =>
      _t('Create your account', 'Cipta akaun anda', '创建您的账户');
  String get username => _t('Username', 'Nama Pengguna', '用户名');
  String get tellAboutYourself => _t(
    'Tell us about yourself',
    'Beritahu kami tentang diri anda',
    '告诉我们关于您自己',
  );
  String get fullName => _t('Full Name', 'Nama Penuh', '全名');
  String get age => _t('Age', 'Umur', '年龄');
  String get selectGender => _t('Select Gender', 'Pilih Jantina', '选择性别');
  String get male => _t('Male', 'Lelaki', '男');
  String get female => _t('Female', 'Perempuan', '女');
  String get preferNotToSay =>
      _t('Prefer not to say', 'Tidak mahu menyatakan', '不愿透露');
  String get whereAreYou =>
      _t('Where are you located?', 'Di mana lokasi anda?', '您在哪里?');
  String get townCity => _t('Town/City', 'Bandar/Bandaraya', '市镇/城市');
  String get state => _t('State', 'Negeri', '州');
  String get country => _t('Country', 'Negara', '国家');
  String get whatDescribesYou => _t(
    'What best describes you?',
    'Apakah yang paling menggambarkan anda?',
    '什么最能描述您?',
  );
  String get selectRole => _t('Select Role', 'Pilih Peranan', '选择角色');
  String get farmer => _t('Farmer', 'Petani', '农民');
  String get homeGrower => _t('Home Grower', 'Penanam Rumah', '家庭种植者');
  String get agronomist => _t('Agronomist', 'Ahli Agronomi', '农学家');
  String get businessCompany =>
      _t('Business Company', 'Syarikat Perniagaan', '商业公司');
  String get finish => _t('Finish', 'Selesai', '完成');
  String get next => _t('Next', 'Seterusnya', '下一步');
  String get pleaseFillAllFields =>
      _t('Please fill in all fields', 'Sila isi semua ruangan', '请填写所有字段');
  String get pleaseSelectRole =>
      _t('Please select a role', 'Sila pilih peranan', '请选择角色');
  String get pleaseEnterValidEmail => _t(
    'Please enter a valid email address',
    'Sila masukkan alamat emel yang sah',
    '请输入有效的电子邮件地址',
  );
  String get passwordMinLength => _t(
    'Password must be at least 6 characters',
    'Kata laluan mesti sekurang-kurangnya 6 aksara',
    '密码必须至少6个字符',
  );
  String get usernameTaken => _t(
    'Username is already taken. Please choose another.',
    'Nama pengguna telah diambil. Sila pilih yang lain.',
    '用户名已被使用,请选择另一个。',
  );

  // ═══════════════════════════════════════════════════════════════════════
  //  COMPLETE PROFILE SCREEN
  // ═══════════════════════════════════════════════════════════════════════
  String get completeProfile =>
      _t('Complete Profile', 'Lengkapkan Profil', '完善个人资料');
  String get completeProfileMessage => _t(
    'Please complete your profile to continue.',
    'Sila lengkapkan profil anda untuk meneruskan.',
    '请完善您的个人资料以继续。',
  );
  String get gender => _t('Gender', 'Jantina', '性别');
  String get town => _t('Town', 'Bandar', '市镇');
  String get role => _t('Role', 'Peranan', '角色');
  String get buyer => _t('Buyer', 'Pembeli', '买家');
  String get investor => _t('Investor', 'Pelabur', '投资者');
  String get researcher => _t('Researcher', 'Penyelidik', '研究员');
  String get other => _t('Other', 'Lain-lain', '其他');
  String get saveAndContinue =>
      _t('Save & Continue', 'Simpan & Teruskan', '保存并继续');
  String get pleaseEnterAge =>
      _t('Please enter your age', 'Sila masukkan umur anda', '请输入您的年龄');
  String get pleaseEnterValidNumber => _t(
    'Please enter a valid number',
    'Sila masukkan nombor yang sah',
    '请输入有效数字',
  );
  String get pleaseEnterTown =>
      _t('Please enter your town', 'Sila masukkan bandar anda', '请输入您的市镇');
  String get pleaseEnterState =>
      _t('Please enter your state', 'Sila masukkan negeri anda', '请输入您的州');
  String get pleaseEnterCountry =>
      _t('Please enter your country', 'Sila masukkan negara anda', '请输入您的国家');

  // ═══════════════════════════════════════════════════════════════════════
  //  BOTTOM NAVIGATION
  // ═══════════════════════════════════════════════════════════════════════
  String get navHome => _t('Home', 'Utama', '首页');
  String get navFarmer => _t('Farmer', 'Petani', '农民');
  String get navScan => _t('Scan', 'Imbas', '扫描');
  String get navMessage => _t('Message', 'Mesej', '消息');
  String get navProfile => _t('Profile', 'Profil', '个人资料');

  // ═══════════════════════════════════════════════════════════════════════
  //  HOME SCREEN
  // ═══════════════════════════════════════════════════════════════════════
  String get searchHint => _t(
    'Search people, crops, pests...',
    'Cari orang, tanaman, perosak...',
    '搜索人物、作物、害虫...',
  );
  String get carbonEmissionReduction =>
      _t('Carbon Emission Reduction', 'Pengurangan Pelepasan Karbon', '碳排放减少');
  String get startPlantingToEarn => _t(
    'Start planting to earn impact',
    'Mula menanam untuk kesan positif',
    '开始种植以获得影响力',
  );
  String get today => _t('Today', 'Hari Ini', '今天');
  String get loading => _t('Loading...', 'Memuatkan...', '加载中...');
  String get unavailable => _t('Unavailable', 'Tidak tersedia', '不可用');
  String get setLocation => _t('Set location', 'Tetapkan lokasi', '设置位置');
  String get myJourney => _t('My Journey', 'Perjalanan Saya', '我的旅程');
  String get dictionary => _t('Dictionary', 'Kamus', '字典');
  String get aiAssistant => _t('AI Assistant', 'Pembantu AI', 'AI 助手');
  String get community => _t('Community', 'Komuniti', '社区');
  String get recommend => _t('Recommend', 'Cadangan', '推荐');
  String get market => _t('Market', 'Pasaran', '市场');
  String get qAndA => _t('Q&A', 'S&J', '问答');
  String get noPostsYet => _t(
    'No posts yet. Be the first to share!',
    'Belum ada siaran. Jadilah yang pertama berkongsi!',
    '还没有帖子。成为第一个分享的人!',
  );

  // ═══════════════════════════════════════════════════════════════════════
  //  FARMER SCREEN
  // ═══════════════════════════════════════════════════════════════════════
  String get farmerHub => _t('Farmer Hub', 'Hab Petani', '农民中心');
  String get agropreneurGuideline =>
      _t('Agropreneur\nGuideline', 'Panduan\nAgropreneur', '农业企业家\n指南');
  String get farmLandRental =>
      _t('Farm Land\nRental', 'Sewa Tanah\nPertanian', '农地\n出租');
  String get marketplaceAndMap =>
      _t('Marketplace &\nMap', 'Pasaran &\nPeta', '市场 &\n地图');
  String get pestDistribution =>
      _t('Pest\nDistribution', 'Taburan\nPerosak', '害虫\n分布');

  // ═══════════════════════════════════════════════════════════════════════
  //  SCAN / DIAGNOSTIC SCREEN
  // ═══════════════════════════════════════════════════════════════════════
  String get aiDiagnostics => _t('AI Diagnostics', 'Diagnostik AI', 'AI 诊断');
  String get analyzing => _t(
    'Agro AI is analyzing...',
    'Agro AI sedang menganalisis...',
    'Agro AI 正在分析...',
  );
  String get gallery => _t('Gallery', 'Galeri', '相册');
  String get camera => _t('Camera', 'Kamera', '相机');
  String get identifyPests =>
      _t('Identify Pests 🐞', 'Kenal Pasti Perosak 🐞', '识别害虫 🐞');
  String get identifyNutrients =>
      _t('Identify Nutrients 🍃', 'Kenal Pasti Nutrien 🍃', '识别营养 🍃');

  // ═══════════════════════════════════════════════════════════════════════
  //  MESSAGE SCREEN
  // ═══════════════════════════════════════════════════════════════════════
  String get search => _t('Search', 'Cari', '搜索');
  String get chats => _t('Chats', 'Sembang', '聊天');
  String get requests => _t('Requests', 'Permintaan', '请求');
  String get errorLoadingRequests =>
      _t('Error loading requests', 'Ralat memuatkan permintaan', '加载请求出错');
  String get noFriendRequestsYet =>
      _t('No friend requests yet', 'Belum ada permintaan rakan', '还没有好友请求');
  String get sentFriendRequest => _t(
    'Sent you a friend request',
    'Menghantar permintaan rakan kepada anda',
    '向您发送了好友请求',
  );
  String get addFriendsToChat => _t(
    'Add friends to start chatting!',
    'Tambah rakan untuk mula bersembang!',
    '添加好友开始聊天!',
  );
  String get tapToChat => _t('Tap to chat', 'Ketik untuk sembang', '点击聊天');

  // ═══════════════════════════════════════════════════════════════════════
  //  PROFILE SCREEN
  // ═══════════════════════════════════════════════════════════════════════
  String get userNotFound =>
      _t('User not found', 'Pengguna tidak dijumpai', '用户未找到');
  String get settingsComingSoon => _t(
    'Settings menu coming soon!',
    'Menu tetapan akan datang!',
    '设置菜单即将推出!',
  );
  String get personalDetails =>
      _t('Personal details', 'Maklumat peribadi', '个人详情');
  String get yearsOld => _t('years old', 'tahun', '岁');
  String get friends => _t('Friends', 'Rakan', '好友');
  String get posts => _t('Posts', 'Siaran', '帖子');
  String get seeAll => _t('See all', 'Lihat semua', '查看全部');
  String get noFriendsYet =>
      _t('No friends yet.', 'Belum mempunyai rakan.', '还没有好友。');
  String get noPostsFound =>
      _t('No posts found.', 'Tiada siaran dijumpai.', '未找到帖子。');
  String get createAPost => _t('Create a post', 'Cipta siaran', '创建帖子');
  String get editProfile => _t('Edit profile', 'Sunting profil', '编辑资料');
  String get logout => _t('Logout', 'Log Keluar', '退出登录');
  String get logOut => _t('Log Out', 'Log Keluar', '退出');
  String get logoutConfirm => _t(
    'Are you sure you want to logout?',
    'Adakah anda pasti mahu log keluar?',
    '您确定要退出登录吗?',
  );
  String get cancel => _t('Cancel', 'Batal', '取消');
  String get deletePost => _t('Delete Post', 'Padam Siaran', '删除帖子');
  String get deletePostConfirm => _t(
    'Are you sure you want to delete this post?',
    'Adakah anda pasti mahu memadam siaran ini?',
    '您确定要删除此帖子吗?',
  );
  String get delete => _t('Delete', 'Padam', '删除');
  String get like => _t('Like', 'Suka', '赞');
  String get comment => _t('Comment', 'Komen', '评论');
  String get send => _t('Send', 'Hantar', '发送');
  String get justNow => _t('Just now', 'Baru sahaja', '刚刚');
  String get comments => _t('comments', 'komen', '条评论');

  // ═══════════════════════════════════════════════════════════════════════
  //  EDIT PROFILE SCREEN
  // ═══════════════════════════════════════════════════════════════════════
  String get editProfileTitle => _t('Edit profile', 'Sunting profil', '编辑资料');
  String get save => _t('Save', 'Simpan', '保存');
  String get changePhoto => _t('Change photo', 'Tukar foto', '更换照片');
  String get name => _t('Name', 'Nama', '名字');
  String get bio => _t('Bio', 'Bio', '简介');

  // ═══════════════════════════════════════════════════════════════════════
  //  LANGUAGE SETTINGS
  // ═══════════════════════════════════════════════════════════════════════
  String get languageSetting => _t('Language', 'Bahasa', '语言');
  String get languageSettingDesc =>
      _t('Change app language', 'Tukar bahasa aplikasi', '更改应用语言');

  // ═══════════════════════════════════════════════════════════════════════
  //  MISC / SHARED
  // ═══════════════════════════════════════════════════════════════════════
  String get errorUpdatingProfile =>
      _t('Error updating profile', 'Ralat mengemas kini profil', '更新个人资料出错');
  String get errorSavingProfile =>
      _t('Error saving profile', 'Ralat menyimpan profil', '保存个人资料出错');

  // Helper for friend count + posts format
  String friendsAndPosts(int friendCount, int postCount) => _t(
    '$friendCount friends • $postCount posts',
    '$friendCount rakan • $postCount siaran',
    '$friendCount 好友 • $postCount 帖子',
  );

  // Helper for plant count
  String plantsContributing(int count) => _t(
    '$count ${count == 1 ? 'plant' : 'plants'} contributing',
    '$count tanaman menyumbang',
    '$count 棵植物正在贡献',
  );

  // ═══════════════════════════════════════════════════════════════════════
  //  AI ASSISTANT SCREEN
  // ═══════════════════════════════════════════════════════════════════════
  String get aiAssistantTitle =>
      _t('AI Plantation Assistant', 'Pembantu Perladangan AI', 'AI 种植助理');
  String get aiWelcomeMessage => _t(
    "Hello! I'm your AI Plantation Assistant. I can help you with:\n\n• Plant care advice\n• Pest & disease diagnosis\n• Growing tips for your region\n• Watering & fertilizer guidance\n• Weather-based recommendations\n\nWhat would you like to know?",
    "Hai! Saya pembantu perladangan AI anda. Saya boleh membantu anda dengan:\n\n• Nasihat penjagaan tanaman\n• Diagnosis perosak & penyakit\n• Tips penanaman untuk kawasan anda\n• Panduan penyiraman & baja\n• Cadangan berdasarkan cuaca\n\nApa yang anda ingin tahu?",
    "你好！我是你的AI种植助手。我可以帮助你：\n\n• 植物护理建议\n• 害虫和病害诊断\n• 适合你所在地区的种植技巧\n• 浇水和施肥指导\n• 基于天气的推荐\n\n你想了解什么？",
  );
  String get thinking => _t('Thinking...', 'Sedang berfikir...', '正在思考...');
  String get askAboutPlants => _t(
    'Ask about your plants...',
    'Tanya tentang tanaman anda...',
    '询问关于你的植物...',
  );

  // ═══════════════════════════════════════════════════════════════════════
  //  ANALYSIS RESULT SCREEN
  // ═══════════════════════════════════════════════════════════════════════
  String get pestAnalysisResult =>
      _t('Pest Analysis Result', 'Keputusan Analisis Perosak', '害虫分析结果');
  String get nutrientAnalysisResult =>
      _t('Nutrient Analysis Result', 'Keputusan Analisis Nutrien', '营养分析结果');
  String get diagnosisReport =>
      _t('Diagnosis Report:', 'Laporan Diagnosis:', '诊断报告：');
  String get pestNameLabel => _t('Pest Name', 'Nama Perosak', '害虫名称');
  String get deficiencyNameLabel =>
      _t('Deficiency Name', 'Nama Kekurangan', '缺乏症名称');
  String get threatLabel => _t('Threat', 'Ancaman', '威胁');
  String get symptomsLabel => _t('Symptoms', 'Gejala', '症状');
  String get solutionsLabel => _t('Solutions', 'Penyelesaian', '解决方案');
  String get outbreakReported => _t(
    '✅ Outbreak Reported! Alerting nearby farmers...',
    '✅ Wabak Dilaporkan! Memberi amaran kepada petani berhampiran...',
    '✅ 疫情已报告！正在通知附近的农民...',
  );
  String get reportOutbreakHelp => _t(
    'Is this a serious outbreak? Help other farmers by reporting it.',
    'Adakah ini wabak serius? Bantu petani lain dengan melaporkannya.',
    '这是严重的疫情吗？通过举报帮助其他农民。',
  );
  String get reportingLocation =>
      _t('Reporting Location...', 'Melaporkan Lokasi...', '正在报告位置...');
  String get reportOutbreak =>
      _t('REPORT OUTBREAK 🚨', 'LAPORKAN WABAK 🚨', '报告疫情 🚨');
  String get backToScan => _t('Back to Scan', 'Kembali ke Imbasan', '返回扫描');

  // ═══════════════════════════════════════════════════════════════════════
  //  GRANT INTRO SCREEN
  // ═══════════════════════════════════════════════════════════════════════
  String get youngAgropreneurGrant =>
      _t('Young Agropreneur\nGrant', 'Geran Agropreneur\nMuda', '青年农业企业家\n补助金');
  String get acceleratingCareer => _t(
    'Accelerating Your Career in Agriculture',
    'Mempercepatkan Kerjaya Anda dalam Pertanian',
    '加速你的农业职业发展',
  );
  String get programOverview =>
      _t('Program Overview', 'Gambaran Program', '项目概述');
  String get programOverviewDesc => _t(
    'The Young Agropreneur Program (PAM) is designed for young individuals aged 18 to 45. It aims to support and encourage youth involvement in agri-entrepreneurship across the entire agricultural value chain.',
    'Program Agropreneur Muda (PAM) direka untuk individu muda berumur 18 hingga 45 tahun. Ia bertujuan menyokong dan menggalakkan penglibatan belia dalam keusahawanan pertanian merentasi seluruh rantaian nilai pertanian.',
    '青年农业企业家计划（PAM）专为18至45岁的年轻人设计。旨在支持和鼓励青年参与整个农业价值链的农业创业。',
  );
  String get empoweringNextGen => _t(
    'Empowering the next generation of agricultural entrepreneurs',
    'Memperkasakan generasi usahawan pertanian seterusnya',
    '赋能下一代农业企业家',
  );
  String get viewRequirements =>
      _t('VIEW REQUIREMENTS', 'LIHAT SYARAT', '查看要求');

  // ═══════════════════════════════════════════════════════════════════════
  //  GRANT REQUIREMENTS SCREEN
  // ═══════════════════════════════════════════════════════════════════════
  String get programRequirements =>
      _t('Program Requirements', 'Syarat Program', '项目要求');
  String get eligibilityRequirements =>
      _t('Eligibility & Requirements', 'Kelayakan & Syarat', '资格和要求');
  String get reviewCriteria => _t(
    'Review the criteria below to ensure you qualify',
    'Semak kriteria di bawah untuk memastikan anda layak',
    '查看以下标准以确保您符合条件',
  );
  String get programObjectives =>
      _t('Program Objectives', 'Objektif Program', '项目目标');
  String get objective1 => _t(
    'Attract youth aged 18-45 to venture into agriculture',
    'Menarik belia berumur 18-45 untuk menceburi pertanian',
    '吸引18-45岁的青年投身农业',
  );
  String get objective2 => _t(
    'Change perception of agriculture as a viable industry',
    'Mengubah persepsi pertanian sebagai industri yang berdaya maju',
    '改变对农业作为可行产业的认知',
  );
  String get objective3 => _t(
    'Increase income through technology',
    'Meningkatkan pendapatan melalui teknologi',
    '通过技术增加收入',
  );
  String get eligibilityReqs =>
      _t('Eligibility Requirements', 'Syarat Kelayakan', '资格要求');
  String get basicRequirements =>
      _t('Basic Requirements', 'Syarat Asas', '基本要求');
  String get generalEligibility =>
      _t('General eligibility criteria', 'Kriteria kelayakan am', '一般资格标准');
  String get req1 => _t('Malaysian citizen', 'Warganegara Malaysia', '马来西亚公民');
  String get req2 => _t(
    'Aged between 18 and 45 years',
    'Berumur antara 18 dan 45 tahun',
    '年龄在18至45岁之间',
  );
  String get req3 => _t(
    'Able to read, count, and write',
    'Boleh membaca, mengira, dan menulis',
    '能够阅读、计算和书写',
  );
  String get startupRequirements =>
      _t('Start-up Requirements', 'Syarat Permulaan', '启动要求');
  String get additionalCriteria => _t(
    'Additional criteria for new ventures',
    'Kriteria tambahan untuk usaha baharu',
    '新项目的附加标准',
  );
  String get startupReq1 => _t(
    'Aged between 18 and 43 years',
    'Berumur antara 18 dan 43 tahun',
    '年龄在18至43岁之间',
  );
  String get startupReq2 => _t(
    'Must attend technical training (unless exempted)',
    'Mesti menghadiri latihan teknikal (kecuali dikecualikan)',
    '必须参加技术培训（除非获得豁免）',
  );
  String get startupReq3 => _t(
    'Net income less than RM5,000 per month',
    'Pendapatan bersih kurang daripada RM5,000 sebulan',
    '每月净收入低于RM5,000',
  );
  String get startApplication =>
      _t('START APPLICATION', 'MULA PERMOHONAN', '开始申请');

  // ═══════════════════════════════════════════════════════════════════════
  //  GRANT TUTORIAL SCREEN
  // ═══════════════════════════════════════════════════════════════════════
  String get grantTutorial =>
      _t('Grant Application Tutorial', 'Tutorial Permohonan Geran', '补助金申请教程');
  String get previous => _t('Previous', 'Sebelumnya', '上一步');

  // ═══════════════════════════════════════════════════════════════════════
  //  LAND LISTING SCREEN
  // ═══════════════════════════════════════════════════════════════════════
  String get farmLandRentalTitle =>
      _t('Farm Land Rental', 'Sewa Tanah Pertanian', '农地出租');
  String get searchByTitleOrLocation => _t(
    'Search by title or location...',
    'Cari mengikut tajuk atau lokasi...',
    '按标题或位置搜索...',
  );
  String get allStates => _t('All States', 'Semua Negeri', '所有州');
  String get anyPrice => _t('Any Price', 'Sebarang Harga', '任何价格');
  String get forRent => _t('For Rent', 'Untuk Disewa', '出租');
  String get contactOwner => _t('Contact Owner', 'Hubungi Pemilik', '联系业主');
  String get contactOwnerInfo => _t(
    'Contact owner for further information',
    'Hubungi pemilik untuk maklumat lanjut',
    '联系业主获取更多信息',
  );
  String get ownerPhoneNumber =>
      _t('Owner Phone Number:', 'Nombor Telefon Pemilik:', '业主电话号码：');
  String get close => _t('Close', 'Tutup', '关闭');
  String get noLandsFound =>
      _t('No lands found', 'Tiada tanah dijumpai', '未找到土地');

  // ═══════════════════════════════════════════════════════════════════════
  //  NOTIFICATION SCREEN
  // ═══════════════════════════════════════════════════════════════════════
  String get notifications => _t('Notifications', 'Pemberitahuan', '通知');
  String get clearAll => _t('Clear All', 'Padam Semua', '全部清除');
  String get noNewAlerts => _t(
    'No new alerts. Your crops are safe!',
    'Tiada amaran baharu. Tanaman anda selamat!',
    '没有新警报。您的作物安全！',
  );

  // ═══════════════════════════════════════════════════════════════════════
  //  MY GARDEN (HOME SCREEN)
  // ═══════════════════════════════════════════════════════════════════════
  String get myGarden => _t('My Garden', 'Kebun Saya', '我的花园');
  String get communityMember => _t('Community Member', 'Ahli Komuniti', '社区成员');
  String get home => _t('Home', 'Rumah', '首页');

  // ═══════════════════════════════════════════════════════════════════════
  //  COMMUNITY / CREATE POST SCREEN
  // ═══════════════════════════════════════════════════════════════════════
  String get createPostTitle => _t('Create Post', 'Cipta Siaran', '创建帖子');
  String get whatsOnYourMind =>
      _t("What's on your mind?", 'Apa yang ada di fikiran anda?', '你在想什么？');
  String get post => _t('Post', 'Siaran', '发布');
  String get writeACaption =>
      _t('Write a caption...', 'Tulis kapsyen...', '写下标题...');
  String get errorCreatingPost =>
      _t('Error creating post', 'Ralat mencipta siaran', '创建帖子出错');
  String get newPostTitle => _t('New Post', 'Siaran Baharu', '新帖子');
  String get sharePost => _t('Share', 'Kongsi', '分享');
  String get addPhoto => _t('Add Photo', 'Tambah Foto', '添加照片');

  // Step indicator
  String stepOf(int current, int total) => _t(
    'Step $current of $total',
    'Langkah $current daripada $total',
    '第 $current 步，共 $total 步',
  );

  // Navigation
  String get nextButton => _t('Next', 'Seterusnya', '下一步');
  String get finishButton => _t('Finish', 'Selesai', '完成');

  // ── Home Screen (additional) ──
  String kgToNextLevel(String kg, int level) =>
      _t('$kg kg to L$level', '$kg kg ke L$level', '$kg 千克到 L$level');
  String daysLabel(int days) => _t('$days days', '$days hari', '$days 天');
  String get setInMyJourney =>
      _t('Set in My Journey', 'Tetapkan di Perjalanan Saya', '在我的旅途中设置');
  String get errorLoadingPosts =>
      _t('Error loading posts', 'Ralat memuatkan siaran', '加载帖子出错');

  // Weather conditions
  String get clearSky => _t('Clear sky', 'Langit cerah', '晴天');
  String get partlyCloudy => _t('Partly cloudy', 'Separa berawan', '多云');
  String get cloudy => _t('Cloudy', 'Berawan', '阴天');
  String get fog => _t('Fog', 'Kabus', '雾');
  String get drizzle => _t('Drizzle', 'Renyai', '毛毛雨');
  String get freezingDrizzle => _t('Freezing drizzle', 'Renyai beku', '冻毛毛雨');
  String get rain => _t('Rain', 'Hujan', '雨');
  String get freezingRain => _t('Freezing rain', 'Hujan beku', '冻雨');
  String get snow => _t('Snow', 'Salji', '雪');
  String get rainShowers => _t('Rain showers', 'Hujan lebat', '阵雨');
  String get snowShowers => _t('Snow showers', 'Hujan salji', '阵雪');
  String get thunderstorm => _t('Thunderstorm', 'Ribut petir', '雷暴');
  String get unknownWeather => _t('Unknown', 'Tidak diketahui', '未知');

  // ── Pest Distribution Map ──
  String get pestDistributionMap =>
      _t('Pest Distribution Map', 'Peta Taburan Perosak', '害虫分布地图');
  String get myReportsTitle => _t('My Reports', 'Laporan Saya', '我的报告');
  String get recentPestAlerts => _t(
    'Recent Pest Alerts in Malaysia',
    'Amaran Perosak Terkini di Malaysia',
    '马来西亚最新害虫警报',
  );
  String get errorLoadingAlerts =>
      _t('Error loading alerts.', 'Ralat memuatkan amaran.', '加载警报出错。');
  String get noRecentAlerts =>
      _t('No recent alerts.', 'Tiada amaran terkini.', '没有最新警报。');
  String get locationUnknown =>
      _t('Location unknown', 'Lokasi tidak diketahui', '位置未知');
  String get clearOutbreakTitle =>
      _t('Clear Outbreak?', 'Hapuskan Wabak?', '清除疫情？');
  String get clearOutbreakContent => _t(
    'Has this pest outbreak been resolved? This will permanently remove the danger zone from the map for all farmers.',
    'Adakah wabak perosak ini telah diselesaikan? Ini akan membuang zon bahaya dari peta untuk semua petani.',
    '此害虫疫情已解决吗？这将永久从地图上移除所有农民的危险区域。',
  );
  String get yesClearIt => _t('Yes, Clear It', 'Ya, Hapuskan', '是的，清除');
  String get outbreakCleared => _t(
    'Outbreak cleared! Map updated.',
    'Wabak dihapuskan! Peta dikemaskini.',
    '疫情已清除！地图已更新。',
  );
  String get tapToClear => _t(
    'Tap here to mark as CLEARED ✅',
    'Ketik di sini untuk tanda SELESAI ✅',
    '点击此处标记为已清除 ✅',
  );
  String get reportedOutbreakCenter =>
      _t('Reported Outbreak Center', 'Pusat Wabak Dilaporkan', '报告的疫情中心');
  String get networkError => _t('Network error.', 'Ralat rangkaian.', '网络错误。');
  String get cleared => _t('CLEARED', 'SELESAI', '已清除');

  // ── My Reports Screen ──
  String get myOutbreakReports =>
      _t('My Outbreak Reports', 'Laporan Wabak Saya', '我的疫情报告');
  String get outbreakMarkedCleared => _t(
    'Outbreak marked as cleared!',
    'Wabak ditandakan sebagai selesai!',
    '疫情已标记为已清除！',
  );
  String get pleaseLoginReports => _t(
    'Please log in to view your reports.',
    'Sila log masuk untuk melihat laporan anda.',
    '请登录查看您的报告。',
  );
  String get errorLoadingReports =>
      _t('Error loading reports.', 'Ralat memuatkan laporan.', '加载报告出错。');
  String get noOutbreaksYet => _t(
    "You haven't reported any outbreaks yet.",
    'Anda belum melaporkan sebarang wabak.',
    '您尚未报告任何疫情。',
  );
  String get active => _t('ACTIVE', 'AKTIF', '活跃');
  String get markAsCleared => _t(
    'Mark Outbreak as Cleared',
    'Tandakan Wabak Sebagai Selesai',
    '标记疫情为已清除',
  );

  // ── Marketplace Screen ──
  String get marketplace => _t('Marketplace', 'Pasaran', '市场');
  String get searchByCropOrLocation => _t(
    'Search by crop or location',
    'Cari mengikut tanaman atau lokasi',
    '按作物或地点搜索',
  );
  String get noProductsYet => _t(
    'No products yet. Check back soon!',
    'Belum ada produk. Semak semula nanti!',
    '暂无产品，请稍后再来！',
  );
  String noResultsFor(String query) => _t(
    'No results for "$query"',
    'Tiada keputusan untuk "$query"',
    '没有"$query"的结果',
  );
  String weightKg(String weight) =>
      _t('Weight: $weight kg', 'Berat: $weight kg', '重量：$weight 千克');
  String harvestDateLabel(String date) =>
      _t('Harvest Date: $date', 'Tarikh Tuai: $date', '收获日期：$date');
  String contactLabel(String contact) =>
      _t('Contact: $contact', 'Hubungi: $contact', '联系方式：$contact');

  // ── My Product Screen ──
  String get myProducts => _t('My Products', 'Produk Saya', '我的产品');
  String get addProduct => _t('Add Product', 'Tambah Produk', '添加产品');
  String get editProduct => _t('Edit Product', 'Edit Produk', '编辑产品');
  String get pleaseLoginProducts => _t(
    'Please log in to view your products.',
    'Sila log masuk untuk melihat produk anda.',
    '请登录查看您的产品。',
  );
  String get noProductsAddOne => _t(
    'No products yet. Tap "+" to add one.',
    'Belum ada produk. Ketik "+" untuk tambah.',
    '暂无产品。点击"+"添加。',
  );
  String get deleteProductTitle =>
      _t('Delete product?', 'Padam produk?', '删除产品？');
  String get actionCannotBeUndone => _t(
    'This action cannot be undone.',
    'Tindakan ini tidak boleh dibatalkan.',
    '此操作无法撤消。',
  );
  String get productDeleted =>
      _t('Product deleted', 'Produk dipadamkan', '产品已删除');
  String get productSaved => _t('Product saved', 'Produk disimpan', '产品已保存');
  String get selectCrop => _t('Select a crop', 'Pilih tanaman', '选择作物');
  String get crop => _t('Crop', 'Tanaman', '作物');
  String get weightKgLabel => _t('Weight (kg)', 'Berat (kg)', '重量（千克）');
  String get enterValidWeight =>
      _t('Enter a valid weight', 'Masukkan berat yang sah', '请输入有效重量');
  String get harvestDate => _t('Harvest Date', 'Tarikh Tuai', '收获日期');
  String get contactNumber => _t('Contact Number', 'Nombor Telefon', '联系电话');
  String get enterContactNumber =>
      _t('Enter a contact number', 'Masukkan nombor telefon', '请输入联系电话');
  String get address => _t('Address', 'Alamat', '地址');
  String get useCurrent => _t('Use Current', 'Guna Semasa', '使用当前位置');
  String get tapToAddPhoto =>
      _t('Tap to add photo', 'Ketik untuk tambah foto', '点击添加照片');
  String get takePhoto => _t('Take Photo', 'Ambil Foto', '拍照');
  String get pickFromGallery =>
      _t('Pick from Gallery', 'Pilih dari Galeri', '从相册选择');
  String get harvested => _t('Harvested', 'Dituai', '已收获');
  String get edit => _t('Edit', 'Edit', '编辑');

  // ── Map Screen ──
  String get map => _t('Map', 'Peta', '地图');
  String get myProduct => _t('My Product', 'Produk Saya', '我的产品');
  String get phone => _t('Phone', 'Telefon', '电话');
  String get removeProfileTitle =>
      _t('Remove profile?', 'Buang profil?', '删除个人资料？');
  String get removeProfileContent => _t(
    'This will remove your public profile from the map. You can publish it again later if needed.',
    'Ini akan membuang profil awam anda dari peta. Anda boleh menerbitkannya semula kemudian jika perlu.',
    '这将从地图中删除您的公开个人资料。如需要，您可以稍后重新发布。',
  );
  String get profileRemoved =>
      _t('Profile removed', 'Profil dibuang', '个人资料已删除');
  String get updateProfile =>
      _t('Update your profile', 'Kemaskini profil anda', '更新您的个人资料');
  String get nameLabel => _t('Name', 'Nama', '姓名');
  String get enterYourName =>
      _t('Enter your name', 'Masukkan nama anda', '请输入您的姓名');
  String get description => _t('Description', 'Penerangan', '描述');
  String get streetCityState =>
      _t('Street, city, state', 'Jalan, bandar, negeri', '街道、城市、州');
  String get useCurrentLocation =>
      _t('Use current location', 'Guna lokasi semasa', '使用当前位置');
  String get makeProfilePublic =>
      _t('Make your profile public?', 'Jadikan profil anda awam?', '公开您的个人资料？');
  String get profilePublished =>
      _t('Profile published', 'Profil diterbitkan', '个人资料已发布');
  String get registerOnMap => _t('Register on Map', 'Daftar di Peta', '在地图上注册');

  // ── Video Call Landing Screen ──
  String get aiVideoCall => _t('AI Video Call', 'Panggilan Video AI', 'AI视频通话');
  String get talkToAiInYourLanguage => _t(
    'Talk to AI in Your Language',
    'Bercakap dengan AI dalam Bahasa Anda',
    '用您的语言与AI对话',
  );
  String get videoCallDescription => _t(
    'Show your crops through the camera and speak in your preferred language. The AI will understand and respond in the same language.',
    'Tunjukkan tanaman anda melalui kamera dan bercakap dalam bahasa pilihan anda. AI akan memahami dan menjawab dalam bahasa yang sama.',
    '通过摄像头展示您的作物，用您喜欢的语言交流。AI将理解并以同样的语言回应。',
  );
  String get selectYourLanguage =>
      _t('Select your language', 'Pilih bahasa anda', '选择您的语言');
  String get showCrops => _t('Show Crops', 'Tunjuk Tanaman', '展示作物');
  String get showCropsDesc => _t(
    'Point your camera at leaves, pests, or soil',
    'Halakan kamera anda ke daun, perosak, atau tanah',
    '将摄像头对准叶子、害虫或土壤',
  );
  String get speakNaturally =>
      _t('Speak Naturally', 'Bercakap Secara Semula Jadi', '自然对话');
  String get speakNaturallyDesc => _t(
    'Describe problems in your own language',
    'Huraikan masalah dalam bahasa anda sendiri',
    '用您自己的语言描述问题',
  );
  String get aiAnalysis => _t('AI Analysis', 'Analisis AI', 'AI分析');
  String get aiAnalysisDesc => _t(
    'Get instant diagnosis and treatment advice',
    'Dapatkan diagnosis segera dan nasihat rawatan',
    '获取即时诊断和治疗建议',
  );
  String get voiceResponse => _t('Voice Response', 'Respons Suara', '语音回复');
  String get voiceResponseDesc => _t(
    'AI speaks back to you in your language',
    'AI bercakap kembali kepada anda dalam bahasa anda',
    'AI用您的语言回复您',
  );
  String get startVideoCall =>
      _t('Start Video Call', 'Mulakan Panggilan Video', '开始视频通话');
  String get requiresCameraMic => _t(
    'Requires camera and microphone access',
    'Memerlukan akses kamera dan mikrofon',
    '需要摄像头和麦克风权限',
  );

  // ── Search Users Screen ──
  String get searchPeople => _t('Search people...', 'Cari orang...', '搜索用户...');
  String get typeToSearch => _t(
    'Type to search for users.',
    'Taip untuk mencari pengguna.',
    '输入以搜索用户。',
  );
  String get noUsersFound =>
      _t('No users found.', 'Tiada pengguna ditemui.', '未找到用户。');

  // ── Create Post Screen ──
  String get newPost => _t('New Post', 'Siaran Baru', '新帖子');
  String get share => _t('Share', 'Kongsi', '分享');
  String get writeCaption =>
      _t('Write a caption...', 'Tulis kapsyen...', '写标题...');
  String get tagPeople => _t('Tag people', 'Tag orang', '标记用户');
  String get tagPeopleComingSoon => _t(
    'Tag people feature coming soon!',
    'Ciri tag orang akan datang!',
    '标记用户功能即将推出！',
  );
  String get addLocation => _t('Add location', 'Tambah lokasi', '添加位置');
  String get addLocationComingSoon => _t(
    'Add location feature coming soon!',
    'Ciri tambah lokasi akan datang!',
    '添加位置功能即将推出！',
  );
  String get addAudio => _t('Add audio', 'Tambah audio', '添加音频');
  String get addAudioComingSoon => _t(
    'Add audio feature coming soon!',
    'Ciri tambah audio akan datang!',
    '添加音频功能即将推出！',
  );

  // ── AI Scan / Diagnostics ──
  String get aiDiagnosticsOld => _t('AI Diagnostics', 'Diagnostik AI', 'AI诊断');
  String get scanLeafToDetect => _t(
    'Scan a leaf to detect diseases',
    'Imbas daun untuk mengesan penyakit',
    '扫描叶子以检测疾病',
  );

  // ── Common ──
  String get pending => _t('Pending...', 'Menunggu...', '待处理...');
  String get errorClearingOutbreak =>
      _t('Error clearing outbreak', 'Ralat menghapuskan wabak', '清除疫情出错');
  String get somethingWentWrong =>
      _t('Something went wrong', 'Sesuatu telah berlaku', '出了点问题');
  String get fetchLocation =>
      _t('Fetch location.', 'Dapatkan lokasi.', '获取位置。');
  String get selectACrop => _t('Select a crop.', 'Pilih tanaman.', '请选择作物。');
  String get pickHarvestDate =>
      _t('Pick harvest date.', 'Pilih tarikh tuai.', '请选择收获日期。');
  String get enableLocationServices =>
      _t('Enable location services', 'Hidupkan perkhidmatan lokasi', '启用位置服务');
  String get locationPermissionDenied =>
      _t('Location permission denied', 'Kebenaran lokasi ditolak', '位置权限被拒绝');
}

/// An InheritedWidget that provides LanguageService down the tree
class LanguageServiceProvider extends InheritedNotifier<LanguageService> {
  const LanguageServiceProvider({
    super.key,
    required LanguageService service,
    required super.child,
  }) : super(notifier: service);

  static LanguageService of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<LanguageServiceProvider>();
    return provider!.notifier!;
  }
}
