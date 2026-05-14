import AsyncStorage from '@react-native-async-storage/async-storage';
import { CardItem } from './types';

const CARDS_STORAGE_KEY = '@suxiaobox_cards';

export const saveCards = async (cards: CardItem[]): Promise<void> => {
  try {
    await AsyncStorage.setItem(CARDS_STORAGE_KEY, JSON.stringify(cards));
  } catch (error) {
    console.error('Error saving cards:', error);
  }
};

export const loadCards = async (): Promise<CardItem[]> => {
  try {
    const cardsJson = await AsyncStorage.getItem(CARDS_STORAGE_KEY);
    return cardsJson ? JSON.parse(cardsJson) : [];
  } catch (error) {
    console.error('Error loading cards:', error);
    return [];
  }
};