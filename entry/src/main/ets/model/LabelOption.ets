export interface LabelOption {
  readonly label: string,
  readonly selected: boolean,
  readonly color?: ResourceColor,
  readonly selectedColor?: ResourceColor
}

export interface CopyLabelOption {
  label?: string,
  selected?: boolean,
  color?: ResourceColor,
  selectedColor?: ResourceColor
}

export function copyLabelOption(
  labelOption: LabelOption,
  copyOptions: CopyLabelOption
): LabelOption {
  return {
    label: copyOptions.label ?? labelOption.label,
    selected: copyOptions.selected ?? labelOption.selected,
    color: copyOptions.color ?? labelOption.color,
    selectedColor: copyOptions.selectedColor ?? labelOption.selectedColor
  }
}

export const PREDEFINED_ISSUERS: LabelOption[] = [
  {
    label: 'Huawei',
    selected: false,
    color: '#FFEBEE',
    selectedColor: '#C7000B'
  },
  {
    label: 'Google',
    selected: false,
    color: '#E3F2FD',
    selectedColor: '#0B57D0'
  },
  {
    label: 'Microsoft',
    selected: false,
    color: '#F5F5F5',
    selectedColor: '#2F2F2F'
  },
  {
    label: 'GitHub',
    selected: false,
    color: '#F0F0F0',
    selectedColor: '#24292E'
  },
  {
    label: 'Amazon',
    selected: false,
    color: '#FFF3E0',
    selectedColor: '#E65100'
  },
  {
    label: 'Facebook',
    selected: false,
    color: '#E3F2FD',
    selectedColor: '#1877F2'
  },
  {
    label: 'Twitter (X)',
    selected: false,
    color: '#F5F5F5',
    selectedColor: '#000000'
  },
  {
    label: 'Apple',
    selected: false,
    color: '#EEEEEE',
    selectedColor: '#000000'
  },
  {
    label: 'Dropbox',
    selected: false,
    color: '#E3F2FD',
    selectedColor: '#0061FF'
  },
  {
    label: 'Slack',
    selected: false,
    color: '#F3E5F5',
    selectedColor: '#611F69'
  },
  {
    label: 'Stripe',
    selected: false,
    color: '#EDE7F6',
    selectedColor: '#635BFF'
  },
  {
    label: 'PayPal',
    selected: false,
    color: '#E3F2FD',
    selectedColor: '#003087'
  },
  {
    label: 'Ubisoft',
    selected: false,
    color: '#F5F5F5',
    selectedColor: '#000000'
  },
  {
    label: 'Steam',
    selected: false,
    color: '#ECEFF1',
    selectedColor: '#171A21'
  },
  {
    label: 'Reddit',
    selected: false,
    color: '#FFEBEE',
    selectedColor: '#FF4500'
  },
  {
    label: 'LinkedIn',
    selected: false,
    color: '#E3F2FD',
    selectedColor: '#0A66C2'
  },
  {
    label: 'Other',
    selected: false,
    color: '#ffe4fde3',
    selectedColor: '#ff335133'
  }
];

export const PREDEFINED_LABELS: LabelOption[] = [
  {
    label: 'Personal',
    selected: false,
    color: '#C8E6C9',
    selectedColor: '#2E7D32'
  },
  {
    label: 'Work',
    selected: false,
    color: '#BBDEFB',
    selectedColor: '#0B57D0'
  },
  {
    label: 'Admin',
    selected: false,
    color: '#E1BEE7',
    selectedColor: '#6A0080'
  },
  {
    label: 'Finance',
    selected: false,
    color: '#FFE0B2',
    selectedColor: '#E65100'
  },
  {
    label: 'Shopping',
    selected: false,
    color: '#F8BBD0',
    selectedColor: '#AD1457'
  },
  {
    label: 'Gaming',
    selected: false,
    color: '#D7CCC8',
    selectedColor: '#4E342E'
  },
  {
    label: 'Backup',
    selected: false,
    color: '#CFD8DC',
    selectedColor: '#37474F'
  },
  {
    label: 'Testing',
    selected: false,
    color: '#B2DFDB',
    selectedColor: '#00695C'
  },
  {
    label: 'School',
    selected: false,
    color: '#C5CAE9',
    selectedColor: '#283593'
  },
  {
    label: 'Family',
    selected: false,
    color: '#FFCCBC',
    selectedColor: '#BF360C'
  }
];