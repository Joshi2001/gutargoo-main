import 'package:get/get.dart';
import 'package:gutrgoopro/potli/home/model/potli_home_banner.dart';
import 'package:gutrgoopro/potli/home/model/potli_home_model.dart';
import 'package:gutrgoopro/potli/home/model/potli_home_section.dart';
import 'package:gutrgoopro/potli/home/service/potli_home_service.dart';


class PotliController extends GetxController {
  final RxList<PotliBannerModel> bannerMovies = <PotliBannerModel>[].obs;
  final RxList<PotliMovieModel> featuredMovies = <PotliMovieModel>[].obs;
  final RxList<PotliSectionModel> homeSections = <PotliSectionModel>[].obs;

  final RxBool isLoadingBanners = true.obs;
  final RxBool isLoadingSections = true.obs;
  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
  }
  Future<void> fetchHomeData() async {
    isLoadingBanners.value = true;
    isLoadingSections.value = true;

    await Future.wait([
      _fetchBanners(),
      _fetchSections(),
    ]);
  }

  Future<void> _fetchBanners() async {
    try {
      final banners = await PotliService.fetchBanners();
      bannerMovies.assignAll(banners);

      if (banners.isEmpty) {
        final featured = await PotliService.fetchFeaturedMovies();
        featuredMovies.assignAll(featured);
      }
    } catch (_) {
      bannerMovies.clear();
    } finally {
      isLoadingBanners.value = false;
    }
  }

  Future<void> _fetchSections() async {
    try {
      final sections = await PotliService.fetchSections();
      homeSections.assignAll(sections);
    } catch (_) {
      homeSections.clear();
    } finally {
      isLoadingSections.value = false;
    }
  }
}