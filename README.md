# AFNetworking Performance Test
I've noticed that UI performance - especially FPS while scrolling - drops significantly when downloading files with AFNetworking. I've created this project to demonstrate the issue to the AFNetworking team. Simply launch the app (on a real device, preferably something older like an iPhone 4) and try scrolling the collection view: It should be perfectly smooth. Now tap the plus button in the top right corner. Each tap starts an additional download. Now try scrolling again: It stutters very noticeably.

App is based on the CollectionView-Simple sample by Apple, Inc.

## Details

![Instruments Screenshot](https://github.com/jfahrenkrug/AFNetworkingPerformanceTest/raw/master/instruments.png)

You can see that at time index 0:38 I start a download and the framerate drops significantly.
