export const MessageTypeIds = {
  Text: 1,
  Sticker: 2,
  Image: 3,
  Video: 4,
  Audio: 5,
  Location: 6,
  Imagemap: 7,
  TemplateButtons: 8,
  TemplateConfirm: 9,
  TemplateCarousel: 10,
  TemplateImageCarousel: 11,
  Flex: 12
};

export const MessageType = {
  Text: 'text',
  Sticker: 'sticker',
  Image: 'image',
  Video: 'video',
  Audio: 'audio',
  Location: 'location',
  Imagemap: 'imagemap',
  Template: 'template',
  Flex: 'flex'
};

export const MessageDeliveriesStatus = {
  Pending: 'pending',
  Draft: 'draft'
};

export const TemplateMessageType = {
  Buttons: 'buttons',
  Confirm: 'confirm',
  Carousel: 'carousel',
  ImageCarousel: 'image_carousel'
};

export const ActionObjectsType = {
  Postback: 'postback',
  Message: 'message',
  Uri: 'uri',
  Tel: 'tel',
  Survey: 'survey',
  Datetimepicker: 'datetimepicker',
  Camera: 'camera',
  CameraRoll: 'cameraRoll',
  Location: 'location'
};

export const ImageType = ['image/jpeg', 'image/png', 'image/jpg'];

export const VideoType = ['video/mp4'];

export const AudioType = ['audio/m4a', 'audio/x-m4a', 'audio/wav', 'audio/x-wav', 'audio/mpeg',
  'audio/mpeg3', 'audio/x-mpeg-3', 'audio/ogg'];

export const PdfType = ['application/pdf', 'application/x-pdf'];

export const ImageMimeBytes = ['89504e47', 'ffd8ffe0', 'ffd8ffe1', 'ffd8ffe2', 'ffd8ffdb', 'ffd8ffee'];

export const VideoMimeBytes = ['66747970'];

export const AudioMimeBytes = ['464F524D', '664C6143', '52494646', '57415645', '41564920', '4944333', '4f676753'];

export const PdfMimeBytes = ['255044462D'];

export const UploadMaxSize = {
  Image: 10000000,
  Video: 200000000,
  Audio: 200000000,
  Pdf: 10000000,
  RichMenu: 1000000
};

export const Gender = [
  { value: 'all', text: '設定しない' },
  { value: 'male', text: '男性のみ' },
  { value: 'female', text: '女性のみ' }
];

export const Prefecture = [
  { value: 'jp_01', text: '北海道' },
  { value: 'jp_02', text: '青森県 ' },
  { value: 'jp_03', text: '岩手県' },
  { value: 'jp_04', text: '宮城県' },
  { value: 'jp_05', text: '秋田県' },
  { value: 'jp_06', text: '山形県' },
  { value: 'jp_07', text: '福島県' },
  { value: 'jp_08', text: '茨城県' },
  { value: 'jp_09', text: '栃木県' },
  { value: 'jp_10', text: '群馬県' },
  { value: 'jp_11', text: '埼玉県' },
  { value: 'jp_12', text: '千葉県' },
  { value: 'jp_13', text: '東京都' },
  { value: 'jp_14', text: '神奈川県' },
  { value: 'jp_15', text: '新潟県' },
  { value: 'jp_16', text: '富山県' },
  { value: 'jp_17', text: '石川県' },
  { value: 'jp_18', text: '福井県' },
  { value: 'jp_19', text: '山梨県' },
  { value: 'jp_20', text: '長野県' },
  { value: 'jp_21', text: '岐阜県' },
  { value: 'jp_22', text: '静岡県' },
  { value: 'jp_23', text: '愛知県' },
  { value: 'jp_24', text: '三重県' },
  { value: 'jp_25', text: '滋賀県' },
  { value: 'jp_26', text: '京都府' },
  { value: 'jp_27', text: '大阪府' },
  { value: 'jp_28', text: '兵庫県' },
  { value: 'jp_29', text: '奈良県' },
  { value: 'jp_30', text: '和歌山県' },
  { value: 'jp_31', text: '鳥取県' },
  { value: 'jp_32', text: '島根県' },
  { value: 'jp_33', text: '岡山県' },
  { value: 'jp_34', text: '広島県' },
  { value: 'jp_35', text: '山口県' },
  { value: 'jp_36', text: '徳島県' },
  { value: 'jp_37', text: '香川県' },
  { value: 'jp_38', text: '愛媛県' },
  { value: 'jp_39', text: '高知県' },
  { value: 'jp_40', text: '福岡県' },
  { value: 'jp_41', text: '佐賀県' },
  { value: 'jp_42', text: '長崎県' },
  { value: 'jp_43', text: '熊本県' },
  { value: 'jp_44', text: '大分県' },
  { value: 'jp_45', text: '宮崎県' },
  { value: 'jp_46', text: '鹿児島県' },
  { value: 'jp_47', text: '沖縄県' }
];

export const MonthBirthday = [
  { value: 1, text: '1月' },
  { value: 2, text: '2月' },
  { value: 3, text: '3月' },
  { value: 4, text: '4月' },
  { value: 5, text: '5月' },
  { value: 6, text: '6月' },
  { value: 7, text: '7月' },
  { value: 8, text: '8月' },
  { value: 9, text: '9月' },
  { value: 10, text: '10月' },
  { value: 11, text: '11月' },
  { value: 12, text: '12月' }
];

export const MessageDeliveriesStatusFilter = [
  { value: 'all', text: 'すべて' },
  { value: 'done', text: '配信済み' },
  { value: 'pending', text: '配信予約' },
  { value: 'sending', text: '配信待ち' },
  { value: 'draft', text: '下書き' }
];

export const ScenarioStatusFilter = [
  { value: 'all', text: 'すべて' },
  { value: 'enable', text: '配信中' },
  { value: 'disable', text: '停止中' },
  { value: 'draft', text: '下書き' }
];

export const RichMenuValue = {
  201: 6,
  202: 4,
  203: 4,
  204: 3,
  205: 2,
  206: 2,
  207: 1,
  1001: 3,
  1002: 2,
  1003: 2,
  1004: 2,
  1005: 1
};
export const RichMenuBounds = {
  201: [
    { x: 0, y: 0, width: 833, height: 843, crop_index: 0 },
    { x: 833, y: 0, width: 834, height: 843, crop_index: 0 },
    { x: 1667, y: 0, width: 833, height: 843, crop_index: 0 },
    { x: 0, y: 843, width: 833, height: 843, crop_index: 0 },
    { x: 833, y: 843, width: 834, height: 843, crop_index: 0 },
    { x: 1667, y: 843, width: 833, height: 843, crop_index: 0 }
  ],
  202: [
    { x: 0, y: 0, width: 1250, height: 843, crop_index: 3 },
    { x: 1250, y: 0, width: 1250, height: 843, crop_index: 3 },
    { x: 0, y: 843, width: 1250, height: 843, crop_index: 3 },
    { x: 1250, y: 843, width: 1250, height: 843, crop_index: 3 }
  ],
  203: [
    { x: 0, y: 0, width: 2500, height: 843, crop_index: 1 },
    { x: 0, y: 843, width: 833, height: 843, crop_index: 0 },
    { x: 833, y: 843, width: 834, height: 843, crop_index: 0 },
    { x: 1667, y: 843, width: 833, height: 843, crop_index: 0 }
  ],
  204: [
    { x: 0, y: 0, width: 1667, height: 1686, crop_index: 4 },
    { x: 1667, y: 0, width: 833, height: 843, crop_index: 0 },
    { x: 1667, y: 843, width: 833, height: 843, crop_index: 0 }
  ],
  205: [
    { x: 0, y: 0, width: 2500, height: 843, crop_index: 1 },
    { x: 0, y: 843, width: 2500, height: 843, crop_index: 1 }
  ],
  206: [
    { x: 0, y: 0, width: 1250, height: 1686, crop_index: 5 },
    { x: 1250, y: 0, width: 1250, height: 1686, crop_index: 5 }
  ],
  207: [
    { x: 0, y: 0, width: 2500, height: 1686, crop_index: 2 }
  ],
  1001: [
    { x: 0, y: 0, width: 833, height: 843, crop_index: 0 },
    { x: 833, y: 0, width: 834, height: 843, crop_index: 0 },
    { x: 1667, y: 0, width: 833, height: 843, crop_index: 0 }
  ],
  1002: [
    { x: 0, y: 0, width: 833, height: 843, crop_index: 0 },
    { x: 833, y: 0, width: 1667, height: 843, crop_index: 6 }
  ],
  1003: [
    { x: 0, y: 0, width: 1667, height: 843, crop_index: 6 },
    { x: 1667, y: 0, width: 833, height: 843, crop_index: 0 }
  ],
  1004: [
    { x: 0, y: 0, width: 1250, height: 843, crop_index: 3 },
    { x: 1250, y: 0, width: 1250, height: 843, crop_index: 3 }
  ],
  1005: [
    { x: 0, y: 0, width: 2500, height: 843, crop_index: 1 }
  ]
};

export const ImageMapValue = {
  201: 6,
  202: 4,
  203: 3,
  204: 3,
  205: 2,
  206: 2,
  207: 1,
  208: 3
};

// 1040 * 1040
export const ImageMapBounds = {
  201: [
    { x: 0, y: 0, width: 346, height: 520, crop_index: 7 },
    { x: 346, y: 0, width: 348, height: 520, crop_index: 7 },
    { x: 694, y: 0, width: 346, height: 520, crop_index: 7 },
    { x: 0, y: 520, width: 346, height: 520, crop_index: 7 },
    { x: 346, y: 520, width: 348, height: 520, crop_index: 7 },
    { x: 694, y: 520, width: 346, height: 520, crop_index: 7 }
  ],
  202: [
    { x: 0, y: 0, width: 520, height: 520, crop_index: 8 },
    { x: 520, y: 0, width: 520, height: 520, crop_index: 8 },
    { x: 0, y: 520, width: 520, height: 520, crop_index: 8 },
    { x: 520, y: 520, width: 520, height: 520, crop_index: 8 }
  ],
  203: [
    { x: 0, y: 0, width: 1040, height: 346, crop_index: 9 },
    { x: 0, y: 346, width: 1040, height: 348, crop_index: 9 },
    { x: 0, y: 694, width: 1040, height: 346, crop_index: 9 }
  ],
  204: [
    { x: 0, y: 0, width: 520, height: 520, crop_index: 10 },
    { x: 520, y: 0, width: 520, height: 520, crop_index: 8 },
    { x: 0, y: 520, width: 1040, height: 520, crop_index: 8 }
  ],
  205: [
    { x: 0, y: 0, width: 1040, height: 520, crop_index: 10 },
    { x: 0, y: 520, width: 1040, height: 520, crop_index: 10 }
  ],
  206: [
    { x: 0, y: 0, width: 520, height: 1040, crop_index: 12 },
    { x: 520, y: 0, width: 520, height: 1040, crop_index: 12 }
  ],
  207: [
    { x: 0, y: 0, width: 1040, height: 1040, crop_index: 13 }
  ],
  208: [
    { x: 0, y: 0, width: 1040, height: 260, crop_index: 10 },
    { x: 0, y: 260, width: 1040, height: 260, crop_index: 11 },
    { x: 0, y: 520, width: 1040, height: 520, crop_index: 11 }
  ]
};

export const PostbackTypes = {
  text: 'テキスト送信',
  template: 'テンプレート送信',
  scenario: 'シナリオ送信',
  email: 'メール通知',
  tag: 'タグ操作',
  reminder: 'リマインダ操作',
  scoring: 'スコアリング操作',
  rsv_intro: '予約・紹介送信',
  rsv_cancel_intro: '予約・空室待ちキャンセル',
  rsv_contact: '予約・お問い合わせ',
  // precheckin: '予約・事前チェックイン',
  // service_review: 'サービス評価フォーム送信',
  assign_staff: '担当者割り当て',
  none: '何もしない'
};

export const ActionMessage = {
  default: {
    type: 'postback',
    data: {
      actions: [
        { type: 'none' }
      ]
    }
  }
};

export const ActionMessageImageMap = {
  default: {
    type: 'survey',
    label: '',
    content: {
      name: '',
      id: null
    }
  }
};

export const ImageRichMenuSize = [
  '2500x1686',
  '2500x843',
  '1200x810',
  '1200x405',
  '800x540',
  '800x270'
];

export const ImageImageMapSize = [
  '1040'
];

export const ImageImagemapSize = '1040x1040';

export const aspectModes = [
  'cover',
  'fit'
];

export const FontSizeClass = ['XXs', 'Xs', 'Sm', 'Md', 'Lg', 'Xl', 'XXl', '3Xl', '4Xl', '5Xl'];

export const Weekday = [
  { name: '日', value: 'sun' },
  { name: '月', value: 'mon' },
  { name: '火', value: 'tue' },
  { name: '水', value: 'wed' },
  { name: '木', value: 'thu' },
  { name: '金', value: 'fri' },
  { name: '土', value: 'sat' }
];

export const ActionObjectsCollect = [
  {
    id: 8,
    type: 'message',
    title: 'テキストメッセージ',
    description: 'This action can be configured only with quick reply buttons. When a button associated with this action is tapped, the survey screen in LINE is opened.',
    format: {
      type: 'message',
      label: 'テキストメッセージ'
    }
  },
  {
    id: 1,
    title: 'URLを開く',
    type: 'uri',
    description: 'When a control associated with this action is tapped, the URI specified in the uri property is opened.',
    format: {
      type: 'uri',
      label: 'View details',
      uri: 'http://example.com/page/222'
    }
  },
  {
    id: 2,
    title: '電話する',
    type: 'uri',
    description: 'When a control associated with this action is tapped, the URI specified in the uri property is opened.',
    format: {
      type: 'uri',
      label: 'View details',
      uri: 'tel://0987654321'
    }
  },
  // {
  //   id: 3,
  //   type: 'datetimepicker',
  //   title: '時間を選択する',
  //   description: 'When a control associated with this action is tapped, a postback event is returned via webhook with the date and time selected by the user from the date and time selection dialog. The datetime picker action does not support time zones.',
  //   format: {
  //     type: 'datetimepicker',
  //     label: 'Select date',
  //     data: 'storeId=12345',
  //     mode: 'datetime'
  //   }
  // },
  {
    id: 4,
    type: 'cameraRoll',
    title: '写真を送る',
    description: 'This action can be configured only with quick reply buttons. When a button associated with this action is tapped, the camera roll screen in LINE is opened.',
    format: {
      type: 'cameraRoll',
      label: 'Camera roll'
    }
  },
  {
    id: 5,
    type: 'camera',
    title: '写真を撮る',
    description: 'This action can be configured only with quick reply buttons. When a button associated with this action is tapped, the camera screen in LINE is opened.',
    format: {
      type: 'camera',
      label: 'Camera'
    }
  },

  {
    id: 6,
    type: 'location',
    title: '位置情報を送る',
    description: 'This action can be configured only with quick reply buttons. When a button associated with this action is tapped, the location screen in LINE is opened.',
    format: {
      type: 'location',
      label: 'Location'
    }
  },
  {
    id: 7,
    type: 'survey',
    title: '回答フォーム',
    description: 'This action can be configured only with quick reply buttons. When a button associated with this action is tapped, the survey screen in LINE is opened.',
    format: {
      type: 'survey',
      label: '回答フォーム'
    }
  }
];

export const PrecheckinQuestions =
[
  {
    type: 'text',
    order: 0,
    required: true,
    immutable: true,
    content: {
      name: 'survey-question-editor-text-0',
      text: 'お名前 / Name',
      input_name: 'name'
    }
  },
  {
    type: 'text',
    order: 1,
    required: true,
    immutable: true,
    content: {
      name: 'survey-question-editor-text-1',
      text: '電話番号 / Phone Number',
      sub_text: 'ご予約に使った電話番号をご入力してください',
      input_name: 'phone_number'
    }
  },
  {
    type: 'date',
    order: 2,
    required: true,
    immutable: true,
    content: {
      name: 'survey-question-editor-text-2',
      text: 'チェックイン日 / Check-In Date',
      sub_text: 'ご予約のチェックイン日をご入力してください',
      input_name: 'check_in_date'
    }
  },
  {
    type: 'date',
    order: 3,
    required: true,
    immutable: true,
    content: {
      name: 'survey-question-editor-text-3',
      text: 'チェックアウト日 / Check-Out Date',
      sub_text: 'ご予約のチェックアウト日をご入力してください',
      input_name: 'check_out_date'
    }
  },
  {
    type: 'text',
    required: true,
    immutable: true,
    order: 4,
    content: {
      name: 'survey-question-editor-text-4',
      text: '住所 / Address',
      input_name: 'address'
    }
  },
  {
    type: 'pulldown',
    order: 5,
    required: true,
    immutable: true,
    content: {
      text: '性別 / Gender',
      name: 'survey-question-editor-pulldown-5',
      options: [
        {
          value: '男性'
        },
        {
          value: '女性'
        },
        {
          value: 'その他'
        },
        {
          value: '回答しない'
        }
      ]
    }
  },
  {
    type: 'date',
    order: 6,
    required: true,
    immutable: true,
    content: {
      name: 'survey-question-editor-text-6',
      text: '生年月日 / Birthdate',
      input_name: 'birthday'
    }
  },
  {
    type: 'pulldown',
    order: 7,
    required: true,
    immutable: true,
    content: {
      text: 'ご利用シーン / Use Scene',
      name: 'survey-question-editor-pulldown-7',
      options: [
        {
          key: 'single',
          value: '一人'
        },
        {
          key: 'couple',
          value: '恋人'
        },
        {
          key: 'friends',
          value: '友達'
        },
        {
          key: 'family',
          value: '家族'
        },
        {
          key: 'business',
          value: 'ビジネス'
        },
        {
          key: 'other',
          value: 'その他'
        }
      ]
    }
  }
];

export const NormalQuestion =
[
  {
    editing: true,
    required: false,
    type: 'text',
    content: null
  }
];
