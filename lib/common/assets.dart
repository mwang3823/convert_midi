class Assets {
  static const String audioPath  = 'assets/audio';

  static const String jsonConfig = 'assets/json/config.json';
  static const String jsonLoading = 'assets/json/hand_play_piano.json';

  static const String imgPiano   = 'assets/image/img_piano.png';
  static const String imgIconApp = 'assets/image/img_icon_app.png';
  static const String imgIconEmpty = 'assets/image/img_icon_empty.png';

  static const List<Map<String, dynamic>> categorizedPlaylists = [
    {
      'name': 'Nhạc thiếu nhi / vui nhộn',
      'files': [
        {'title': 'Một con vịt', 'path': '$audioPath/mot_con_vit.mid'},
        {'title': 'Chú Ếch Xanh', 'path': '$audioPath/Chú Ếch Xanh.mid'},
        {'title': 'Bingo easy', 'path': '$audioPath/Bingo easy.mid'},
        {'title': 'Jingle Bell', 'path': '$audioPath/Jingle Bell.mid'},
        {'title': 'Chopsticks', 'path': '$audioPath/Chopsticks.mid'},
      ],
    },
    {
      'name': 'Nhạc lễ hội / năm mới',
      'files': [
        {'title': 'Jingle Bell', 'path': '$audioPath/Jingle Bell.mid'},
        {'title': 'Happy New Year', 'path': '$audioPath/Happy_New_Year.mid'},
      ],
    },
    {
      'name': 'Nhạc Việt Nam',
      'files': [
        {'title': 'Hello Vietnam', 'path': '$audioPath/Hello_Vietnam.mid'},
        {'title': 'Mình Cùng Nhau Đóng Băng', 'path': '$audioPath/Minh_Cung_Nhau_dong_Bang_-_Thuy_Chi.mid'},
        {'title': 'Em Gái Mưa', 'path': '$audioPath/Em_gai_mua.mid'},
        {'title': 'Đừng Yêu Nữa Em Mệt Rồi', 'path': '$audioPath/dung-yeu-nua-em-met-roi.mid'},
      ],
    },
    {
      'name': 'Nhạc cổ điển / piano',
      'files': [
        {'title': 'Für Elise', 'path': '$audioPath/Fur Elise_Beethoven.mid'},
        {'title': 'Can Can', 'path': '$audioPath/Can can.mid'},
        {'title': 'Long Long Ago', 'path': '$audioPath/Long_Long_ago.mid'},
        {'title': 'Greensleeves', 'path': '$audioPath/greensleeves.mid'},
      ],
    },
    {
      'name': 'Nhạc piano nhẹ nhàng',
      'files': [
        {'title': 'Maybe', 'path': '$audioPath/Maybe_Yiruma.mid'},
        {'title': 'Love Story', 'path': '$audioPath/Love_Story_Francis_Lai_EasyBeginner.mid'},
        {'title': 'Only You', 'path': '$audioPath/Only_You.mid'},
        {'title': 'Hallelujah', 'path': '$audioPath/Hallelujah.mid'},
      ],
    },
    {
      'name': 'Nhạc phim / anime',
      'files': [
        {'title': 'Castle in the Sky', 'path': '$audioPath/Castle_in_the_Sky_Theme_-_Innocent_Carrying_You___.mid'},
        {'title': 'Love Story', 'path': '$audioPath/Love_Story_Francis_Lai_EasyBeginner.mid'},
        {'title': 'Hello Vietnam', 'path': '$audioPath/Hello_Vietnam.mid'},
      ],
    },
    {
      'name': 'Pop / Rock hiện đại',
      'files': [
        {'title': 'Believer', 'path': '$audioPath/Believer_-_Imagine_Dragons.mid'},
        {'title': 'Em Gái Mưa', 'path': '$audioPath/Em_gai_mua.mid'},
        {'title': 'Đừng Yêu Nữa Em Mệt Rồi', 'path': '$audioPath/dung-yeu-nua-em-met-roi.mid'},
      ],
    },
    {
      'name': 'Nocturne & Nhạc Cổ Điển Nâng Cao',
      'files': [
        {'title': 'Nocturne Op. E♭ - Chopin', 'path': '$audioPath/Chopin__Nocturne_Op__No__E_Flat_Major.mid'},
        {'title': 'Nocturne C minor', 'path': '$audioPath/Nocturne_No__in_C_Minor.mid'},
        {'title': 'Nocturne E major', 'path': '$audioPath/Nocturne_Opus__No__in_E_Major.mid'},
        {'title': 'Nocturne C# minor', 'path': '$audioPath/Nocturne_in_C_sharp_Minor.mid'},
        {'title': 'Moonlight Sonata I - Beethoven', 'path': '$audioPath/Moonlight_Sonata_I.mid'},
        {'title': 'Waltz in A minor - Chopin', 'path': '$audioPath/Waltz_in_A_MinorChopin.mid'},
        {'title': 'Gymnopédie No.1 - Satie', 'path': '$audioPath/Gymnopdie_No___Satie.mid'},
        {'title': 'Passacaglia', 'path': '$audioPath/Passacaglia.mid'},
      ],
    },
    {
      'name': 'Yiruma & Piano Thư Giãn',
      'files': [
        {'title': 'River Flows in You - Yiruma', 'path': '$audioPath/River_Flows_In_You.mid'},
        {'title': 'Kiss the Rain - Yiruma', 'path': '$audioPath/Yiruma__Kiss_the_Rain__th_Anniversary_Version_Piano.mid'},
        {'title': 'Marriage D\'Amour', 'path': '$audioPath/Marriage_D_Amour.mid'},
        {'title': 'Endless Love', 'path': '$audioPath/Endless_Love_Ann_Coong.mid'},
        {'title': 'Je Te Laisserai Des Mots', 'path': '$audioPath/Je_Te_Laisserai_Des_Mots__Patrick_Watson.mid'},
        {'title': 'Những Kẻ Mộng Mơ', 'path': '$audioPath/Nhng_K_Mng_M__An_Coong_Piano_Cover_Sheet.mid'},
      ],
    },
    {
      'name': 'Richard Clayderman',
      'files': [
        {'title': 'A Comme Amour', 'path': '$audioPath/A_Comme_Amour__Richard_Clayderman.mid'},
        {'title': 'Ballade Pour Adeline', 'path': '$audioPath/Ballade_Pour_Adeline__Richard_Clayderman.mid'},
        {'title': 'Lettre à Ma Mère', 'path': '$audioPath/Lettre_A_Ma_Mere__Richard_Clayderman.mid'},
        {'title': 'Love Story - Clayderman', 'path': '$audioPath/Love_Story_Richard_Clayderman.mid'},
        {'title': 'Histoire d\'un Amour', 'path': '$audioPath/French_Dalida__Histoire_dun_Amour.mid'},
      ],
    },
    {
      'name': 'Nhạc phim & game',
      'files': [
        {'title': 'One Summer\'s Day - Spirited Away', 'path': '$audioPath/One_Summers_Day_Spirited_Away.mid'},
        {'title': 'Game of Thrones Theme', 'path': '$audioPath/Game_of_Thrones_Easy_piano.mid'},
        {'title': 'Schindler\'s List Theme', 'path': '$audioPath/Theme_From_Schindlers_List__Piano_Solo.mid'},
        {'title': 'Gravity Falls Opening', 'path': '$audioPath/Gravity_Falls_Opening__Intermediate_Piano_Solo.mid'},
        {'title': 'Your Reality - DDLC', 'path': '$audioPath/Doki_Doki_Literature_Club_OST__Your_Reality.mid'},
        {'title': 'Giorno\'s Theme - JoJo', 'path': '$audioPath/Jojo_s_Bizarre_Adventure_Golden_Wind_Giornos_Theme_Ver_.mid'},
        {'title': 'Bonetrousle - Undertale', 'path': '$audioPath/Undertale_OST__Nyeh_Heh_HehBonetrousle.mid'},
        {'title': 'Sweden - Minecraft', 'path': '$audioPath/Sweden_Minecraft.mid'},
        {'title': 'I Remember My Name - Squid Game', 'path': '$audioPath/Squid_Game_OST__I_Remember_My_Name_Jubinell_Piano_Cover__Sheet_Music.mid'},
        {'title': 'Duet - Omori', 'path': '$audioPath/Omori__Duet_Spoilers.mid'},
        {'title': 'Sakurairo Mau Koro', 'path': '$audioPath/Sakurairo_Mau_Koro_XE_P__Thy_Chi__PIANO__Mika_Nakashima.mid'},
      ],
    },
    {
      'name': 'Nhạc Trịnh Công Sơn',
      'files': [
        {'title': 'Diễm Xưa', 'path': '$audioPath/Dim_Xa__Trnh_Cng_Sn_for_EASY_PIANO.mid'},
        {'title': 'Hạ Trắng', 'path': '$audioPath/H_Trng.mid'},
        {'title': 'Mưa Hồng', 'path': '$audioPath/Ma_Hng.mid'},
        {'title': 'Gió Cuối Đời', 'path': '$audioPath/_Gi_Cun_i__Trnh_Cng_Sn.mid'},
      ],
    },
    {
      'name': 'Ngô Thụy Miên & Nhạc Trữ Tình',
      'files': [
        {'title': 'Riêng Một Góc Trời', 'path': '$audioPath/Ring_Mt_Gc_Tri__Ng_Thy_Min.mid'},
        {'title': 'Bản Tình Ca Cho Em', 'path': '$audioPath/Vietnamese_Ban_Tinh_Ca_Cho_Em_Ng_Thuy_Min.mid'},
        {'title': 'Đóa Hoa Hồng', 'path': '$audioPath/o_la_H_ng__Ng_Thy_Min.mid'},
        {'title': 'Niệm Khúc Cuối', 'path': '$audioPath/Nim_khc_cui.mid'},
        {'title': 'Bản Tình Cuối', 'path': '$audioPath/Bn_tnh_cui.mid'},
        {'title': 'Mưa Thu Cho Em', 'path': '$audioPath/Ma_thu_cho_em.mid'},
        {'title': 'Nhớ Mùa Thu Hà Nội', 'path': '$audioPath/Nh_Ma_Thu_H_Ni__Phin_bn_d__Easy_Piano_version.mid'},
        {'title': 'Bản Tình Ca Đầu Tiên - Duy Khoa', 'path': '$audioPath/Bn_tnh_ca_u_tin__Duy_Khoa.mid'},
      ],
    },
    {
      'name': 'Pop & Ballad quốc tế',
      'files': [
        {'title': 'Hello - Adele', 'path': '$audioPath/Adele__Hello.mid'},
        {'title': 'Easy On Me - Adele', 'path': '$audioPath/Adele__Easy_On_Me_Sheet_Music_Exact_Melody__Lyrics__Second_Voice_Piano__Chords.mid'},
        {'title': 'When I Was Your Man - Bruno Mars', 'path': '$audioPath/When_I_Was_Your_Man__Bruno_Mars.mid'},
        {'title': 'Make You Feel My Love', 'path': '$audioPath/Make_You_Feel_My_Love.mid'},
        {'title': 'Someone You Loved - Lewis Capaldi', 'path': '$audioPath/Someone_You_Loved.mid'},
        {'title': 'Before You Go - Lewis Capaldi', 'path': '$audioPath/Before_you_go__Lewis_Capaldi.mid'},
        {'title': 'See You Again', 'path': '$audioPath/See_You_Again__Wiz_Khalifa___Charlie_Puth_Solo_Piano.mid'},
        {'title': 'Let Her Go - Passenger', 'path': '$audioPath/Let_Her_Go_Passenger.mid'},
        {'title': 'Beautiful in White - Westlife', 'path': '$audioPath/Westlife__Beautiful_in_White.mid'},
        {'title': 'Imagine - John Lennon', 'path': '$audioPath/John_Lennon__Imagine.mid'},
        {'title': 'Thinking Out Loud - Ed Sheeran', 'path': '$audioPath/Ed_SheeranThinking_out_Loud.mid'},
        {'title': 'Fly Me to the Moon', 'path': '$audioPath/Fly_Me_to_the_Moon.mid'},
        {'title': 'I Have a Dream - ABBA', 'path': '$audioPath/I_HAVE_A_DREAM__ABBA.mid'},
        {'title': 'You Say - Lauren Daigle', 'path': '$audioPath/You_Say__Lauren_Daigle.mid'},
        {'title': 'Bella Ciao', 'path': '$audioPath/Bella_Ciao.mid'},
      ],
    },
    {
      'name': 'K-Pop / J-Pop',
      'files': [
        {'title': 'Shut Down - BLACKPINK', 'path': '$audioPath/BLACKPINK__Shut_Down_Music_Sheet_With_Lyrics__Chords.mid'},
        {'title': 'I Need U - BTS', 'path': '$audioPath/BTS_I_NEED_U.mid'},
        {'title': 'Smiley - Yena', 'path': '$audioPath/Yena__Smiley_Jubinell_Piano_Cover__Sheet_Music.mid'},
        {'title': 'Case - Stray Kids', 'path': '$audioPath/Stray_Kids__Case__Sheet_Music__Music_Sheet_Lyrics_Chords_Piano_Tutorial.mid'},
      ],
    },
    {
      'name': 'Nhạc Việt hiện đại',
      'files': [
        {'title': 'Chạy Về Khóc Với Anh - Erik', 'path': '$audioPath/Chy_V_Khc_Vi_Anh__Erik_Erik__yu_ng_kh_qu_th_CHY_V_KHC_VI_ANH_Jubinell_Piano_Cover__Sheet_Music_Chords_Lyrics.mid'},
        {'title': 'Đau Nhất Là Lặng Im - Erik', 'path': '$audioPath/Erik__au_Nht_L_Lng_Im_Sheet_Music__Jubinell_Piano_Cover.mid'},
        {'title': 'Lạc - Rhymastic', 'path': '$audioPath/Lc__Rhymastic__Rhymastic_Lc___Rhymastic.mid'},
        {'title': 'Thay Vì Có Gì Yêu Anh - AMEE', 'path': '$audioPath/Amee__thay_mi_c_gi_yu_anh_Piano__Guitar_Cover__Sheet_Music_Nt_Nhc.mid'},
        {'title': 'Còn Tuổi Nào Cho Em', 'path': '$audioPath/Cn_Tui_No_Cho_Em.mid'},
        {'title': 'Hà Nội Mùa Vắng Những Cơn Mưa', 'path': '$audioPath/H_Ni_Ma_Vng_Nhng_Cn_Ma.mid'},
        {'title': 'Nối Vòng Tay Lớn', 'path': '$audioPath/NI_VNG_TAY_LN.mid'},
        {'title': 'Chiều Nay Không Có Em', 'path': '$audioPath/Chiu_nay_khng_c_em.mid'},
      ],
    },
    {
      'name': 'Giáng sinh',
      'files': [
        {'title': 'Carol of the Bells', 'path': '$audioPath/Carol_of_the_Bells.mid'},
        {'title': 'We Wish You a Merry Christmas', 'path': '$audioPath/We_Wish_You_a_Merry_Christmas.mid'},
        {'title': 'Have Yourself a Merry Little Christmas', 'path': '$audioPath/Have_Yourself_a_Merry_Little_Christmas.mid'},
        {'title': 'Silent Night', 'path': '$audioPath/Piano_SILENT_NIGHT_arrangement_in_Romantic_style.mid'},
        {'title': 'Jingle Bell Rock', 'path': '$audioPath/Jingle_Bell_Rock.mid'},
        {'title': 'Jingle Bells Rag - Hazel Nguyen', 'path': '$audioPath/EPIC_VERSION_JINGLE_BELLS_RAG_IN_SCOTT_JOPLINS_STYLE__arranged_by_Hazel_Nguyen.mid'},
        {'title': 'Happy Birthday', 'path': '$audioPath/Happy_Birthday.mid'},
        {'title': 'You Are My Sunshine', 'path': '$audioPath/You_Are_My_Sunshine.mid'},
      ],
    },
  ];

  static List<Map<String, String>> get midiFiles {
    final List<Map<String, String>> all = [];
    for (var cat in categorizedPlaylists) {
      for (var f in cat['files']) {
        all.add({
          'name': f['title'] as String,
          'path': f['path'] as String,
        });
      }
    }
    return all;
  }
}
