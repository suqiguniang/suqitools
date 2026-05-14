export interface CardItem {
  id: string;
  title: string;
  type: 'web' | 'wol';
  url?: string;
  macAddress?: string;
  ipAddress?: string;
  port?: number;
  icon?: string;
}