module.exports = {
  /** Site MetaData (Required all)*/
  title: `Circuit.Chautauqua`,                           // (* Required)
  description: `一些記錄`, // (* Required)
  author: `Mu Xian Ming`,                         // (* Required)
  language: 'zh-CN',                            // (* Required) html lang, ex. 'en' | 'en-US' | 'ko' | 'ko-KR' | ...
  siteUrl: 'https://marsmxm.github.io',       // (* Required) 
    // ex.'https://junhobaik.github.io'
    // ex.'https://junhobaik.github.io/' << X, Do not enter "/" at the end.

  /** Header */
  profileImageFileName: 'profile.jpg', // include filename extension ex.'profile.jpg'
    // The Profile image file is located at path "./images/"
    // If the file does not exist, it is replaced by a random image.

  /** Home > Bio information*/
  comment: '',
  name: 'Mu Xian Ming',
  company: '',
  location: 'China',
  email: 'marsmxm@gmail.com',
  website: 'http://mxm.ink',           // ex.'https://junhobaik.github.io'
  linkedin: '',                                     // ex.'https://www.linkedin.com/in/junho-baik-16073a19ab'
  facebook: '',                                     // ex.'https://www.facebook.com/zuck' or 'https://www.facebook.com/profile.php?id=000000000000000'
  instagram: '', // ex.'https://www.instagram.com/junhobaik'
  github: 'https://github.com/marsmxm',           // ex.'https://github.com/junhobaik'
  douban: 'https://www.douban.com/people/marsmxm/',
  pocket: 'https://getpocket.com/@2c8d5p99T0Z9cgdh60Aa088A34gTTe6b8e1Ra7qx62d464dc17dt6N82Ac3TH492',

  /** Post */
  enablePostOfContents: true,     // TableOfContents activation (Type of Value: Boolean. Not String)
  disqusShortname: 'Sam',   // comments (Disqus sort-name)
  enableSocialShare: true,        // Social share icon activation (Type of Value: Boolean. Not String)

  /** Optional */
  // googleAnalytics: 'UA-103592668-4',                                  // Google Analytics TrackingID. ex.'UA-123456789-0'
  // googleSearchConsole: 'w-K42k14_I4ApiQKuVPbCRVV-GxlrqWxYoqO94KMbKo', // content value in HTML tag of google search console ownership verification 
  // googleAdsenseSlot: '5214956675',                                    // Google Adsense Slot. ex.'5214956675'
  googleAdsenseClient: 'ca-pub-7709529744132895',                     // Google Adsense Client. ex.'ca-pub-5001380215831339'
    // Please correct the adsense client number(ex.5001380215831339) in the './static/ads.txt' file.
};
