from __future__ import unicode_literals

import re

from .common import InfoExtractor
from ..compat import (
    compat_HTTPError,
    compat_urlparse,
)
from ..utils import (
    ExtractorError,
    parse_duration,
)


class VideoLecturesNetIE(InfoExtractor):
    _VALID_URL = r'http://(?:www\.)?videolectures\.net/(?P<id>[^/#?]+)/*(?:[#?].*)?$'
    IE_NAME = 'videolectures.net'

    _TESTS = [{
        'url': 'http://videolectures.net/promogram_igor_mekjavic_eng/',
        'info_dict': {
            'id': 'promogram_igor_mekjavic_eng',
            'ext': 'mp4',
            'title': 'Automatics, robotics and biocybernetics',
            'description': 'md5:815fc1deb6b3a2bff99de2d5325be482',
            'upload_date': '20130627',
            'duration': 565,
            'thumbnail': 're:http://.*\.jpg',
        },
    }, {
        # video with invalid direct format links (HTTP 403)
        'url': 'http://videolectures.net/russir2010_filippova_nlp/',
        'info_dict': {
            'id': 'russir2010_filippova_nlp',
            'ext': 'flv',
            'title': 'NLP at Google',
            'description': 'md5:fc7a6d9bf0302d7cc0e53f7ca23747b3',
            'duration': 5352,
            'thumbnail': 're:http://.*\.jpg',
        },
        'params': {
            # rtmp download
            'skip_download': True,
        },
    }, {
        'url': 'http://videolectures.net/deeplearning2015_montreal/',
        'info_dict': {
            'id': 'deeplearning2015_montreal',
            'title': 'Deep Learning Summer School, Montreal 2015',
            'description': 'md5:90121a40cc6926df1bf04dcd8563ed3b',
        },
        'playlist_count': 30,
    }]

    def _real_extract(self, url):
        video_id = self._match_id(url)

        smil_url = 'http://videolectures.net/%s/video/1/smil.xml' % video_id

        try:
            smil = self._download_smil(smil_url, video_id)
        except ExtractorError as e:
            if isinstance(e.cause, compat_HTTPError) and e.cause.code == 404:
                # Probably a playlist
                webpage = self._download_webpage(url, video_id)
                entries = [
                    self.url_result(compat_urlparse.urljoin(url, video_url), 'VideoLecturesNet')
                    for _, video_url in re.findall(r'<a[^>]+href=(["\'])(.+?)\1[^>]+id=["\']lec=\d+', webpage)]
                playlist_title = self._html_search_meta('title', webpage, 'title', fatal=True)
                playlist_description = self._html_search_meta('description', webpage, 'description')
                return self.playlist_result(entries, video_id, playlist_title, playlist_description)

        info = self._parse_smil(smil, smil_url, video_id)

        info['id'] = video_id

        switch = smil.find('.//switch')
        if switch is not None:
            info['duration'] = parse_duration(switch.attrib.get('dur'))

        return info
