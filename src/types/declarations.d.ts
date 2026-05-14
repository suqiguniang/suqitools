declare module 'react-native-wake-on-lan' {
  interface WakeOptions {
    address?: string;
    port?: number;
  }

  export function wake(macAddress: string, options?: WakeOptions): Promise<void>;
}

declare module '*.png' {
  const value: any;
  export default value;
}
