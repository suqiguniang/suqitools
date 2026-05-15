import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Modal,
  TextInput,
  TouchableOpacity,
  ScrollView,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { CardItem } from '../types';
import { DEFAULT_MAC, DEFAULT_IP, DEFAULT_PORT } from '../services/wolService';
import { Colors, Spacing, BorderRadius, Shadows } from '../theme';

interface Props {
  visible: boolean;
  onClose: () => void;
  onSave: (card: Omit<CardItem, 'id'>) => void;
  editCard?: CardItem | null;
}

export const AddCardModal: React.FC<Props> = ({ visible, onClose, onSave, editCard }) => {
  const isEditing = !!editCard;

  const [type, setType] = useState<'web' | 'wol'>('web');
  const [title, setTitle] = useState('');
  const [url, setUrl] = useState('');
  const [macAddress, setMacAddress] = useState(DEFAULT_MAC);
  const [ipAddress, setIpAddress] = useState(DEFAULT_IP);
  const [port, setPort] = useState(DEFAULT_PORT.toString());
  const [icon, setIcon] = useState('');

  useEffect(() => {
    if (visible) {
      if (editCard) {
        setType(editCard.type);
        setTitle(editCard.title || '');
        setUrl(editCard.url || '');
        setMacAddress(editCard.macAddress || DEFAULT_MAC);
        setIpAddress(editCard.ipAddress || DEFAULT_IP);
          setPort(editCard.port?.toString() || DEFAULT_PORT.toString());
          setIcon(editCard.icon || '');
      } else {
        setType('web');
        setTitle('');
        setUrl('');
        setMacAddress(DEFAULT_MAC);
        setIpAddress(DEFAULT_IP);
          setPort(DEFAULT_PORT.toString());
          setIcon('');
      }
    }
  }, [visible, editCard]);

  const handleSave = () => {
    if (!title.trim()) return;

    if (type === 'web' && !url.trim()) return;
    if (type === 'wol' && !macAddress.trim()) return;

      onSave({
        type,
        title: title.trim(),
        icon: icon.trim() || undefined,
        url: type === 'web' ? url.trim() : undefined,
        macAddress: type === 'wol' ? macAddress.trim() : undefined,
        ipAddress: type === 'wol' ? ipAddress.trim() || DEFAULT_IP : undefined,
        port: type === 'wol' ? parseInt(port, 10) || DEFAULT_PORT : undefined,
      });

    onClose();
  };

  return (
    <Modal
      visible={visible}
      transparent
      animationType="slide"
      onRequestClose={onClose}
    >
      <View style={styles.overlay}>
        <View style={styles.container}>
          <View style={styles.header}>
            <Text style={styles.headerTitle}>
              {isEditing ? '编辑卡片' : '添加卡片'}
            </Text>
            <TouchableOpacity onPress={onClose}>
              <Icon name="close" size={24} color={Colors.textPrimary} />
            </TouchableOpacity>
          </View>

          <ScrollView style={styles.form}>
            <View style={styles.typeSelector}>
              <TouchableOpacity
                style={[styles.typeButton, type === 'web' && styles.typeButtonActive]}
                onPress={() => setType('web')}
                disabled={isEditing}
              >
                <Icon name="web" size={20} color={type === 'web' ? Colors.surface : Colors.textSecondary} />
                <Text style={[styles.typeText, type === 'web' && styles.typeTextActive]}>
                  网页
                </Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.typeButton, type === 'wol' && styles.typeButtonActive]}
                onPress={() => setType('wol')}
                disabled={isEditing}
              >
                <Icon name="power" size={20} color={type === 'wol' ? Colors.surface : Colors.textSecondary} />
                <Text style={[styles.typeText, type === 'wol' && styles.typeTextActive]}>
                  WOL
                </Text>
              </TouchableOpacity>
            </View>

            <View style={styles.inputGroup}>
              <Text style={styles.label}>标题</Text>
              <TextInput
                style={styles.input}
                value={title}
                onChangeText={setTitle}
                placeholder="输入卡片标题"
                placeholderTextColor={Colors.textDisabled}
              />
            </View>

          <View style={styles.inputGroup}>
            <Text style={styles.label}>图标</Text>
            <TextInput
              style={styles.input}
              value={icon}
              onChangeText={setIcon}
              placeholder="MaterialCommunityIcons 名称，如 github"
              autoCapitalize="none"
              placeholderTextColor={Colors.textDisabled}
            />
          </View>

            {type === 'web' ? (
              <View style={styles.inputGroup}>
                <Text style={styles.label}>网址</Text>
                <TextInput
                  style={styles.input}
                  value={url}
                  onChangeText={setUrl}
                  placeholder="https://example.com"
                  keyboardType="url"
                  autoCapitalize="none"
                  placeholderTextColor={Colors.textDisabled}
                />
              </View>
            ) : (
              <>
                <View style={styles.inputGroup}>
                  <Text style={styles.label}>MAC 地址</Text>
                  <TextInput
                    style={styles.input}
                    value={macAddress}
                    onChangeText={setMacAddress}
                    placeholder="00:E0:4C:4D:1E:38"
                    autoCapitalize="characters"
                    placeholderTextColor={Colors.textDisabled}
                  />
                  <Text style={styles.hint}>默认: {DEFAULT_MAC}</Text>
                </View>
                <View style={styles.inputGroup}>
                  <Text style={styles.label}>IP 地址</Text>
                  <TextInput
                    style={styles.input}
                    value={ipAddress}
                    onChangeText={setIpAddress}
                    placeholder="192.168.1.255"
                    placeholderTextColor={Colors.textDisabled}
                  />
                  <Text style={styles.hint}>默认: {DEFAULT_IP}</Text>
                </View>
                <View style={styles.inputGroup}>
                  <Text style={styles.label}>端口</Text>
                  <TextInput
                    style={styles.input}
                    value={port}
                    onChangeText={setPort}
                    placeholder="9"
                    keyboardType="number-pad"
                    placeholderTextColor={Colors.textDisabled}
                  />
                  <Text style={styles.hint}>默认: {DEFAULT_PORT}</Text>
                </View>
              </>
            )}
          </ScrollView>

          <TouchableOpacity style={styles.saveButton} onPress={handleSave}>
            <Text style={styles.saveButtonText}>
              {isEditing ? '保存修改' : '保存'}
            </Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'flex-end',
  },
  container: {
    backgroundColor: Colors.surface,
    borderTopLeftRadius: BorderRadius.lg,
    borderTopRightRadius: BorderRadius.lg,
    maxHeight: '80%',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: Spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: Colors.border,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: Colors.textPrimary,
  },
  form: {
    padding: Spacing.md,
  },
  typeSelector: {
    flexDirection: 'row',
    marginBottom: Spacing.md,
  },
  typeButton: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: Spacing.md,
    borderRadius: BorderRadius.sm,
    backgroundColor: Colors.background,
    marginHorizontal: 4,
    gap: 8,
  },
  typeButtonActive: {
    backgroundColor: Colors.primary,
  },
  typeText: {
    fontSize: 14,
    color: Colors.textSecondary,
    fontWeight: '500',
  },
  typeTextActive: {
    color: Colors.surface,
  },
  inputGroup: {
    marginBottom: Spacing.md,
  },
  label: {
    fontSize: 14,
    fontWeight: '500',
    color: Colors.textPrimary,
    marginBottom: 6,
  },
  input: {
    borderWidth: 1,
    borderColor: Colors.border,
    borderRadius: BorderRadius.sm,
    padding: Spacing.md,
    fontSize: 14,
    color: Colors.textPrimary,
  },
  hint: {
    fontSize: 12,
    color: Colors.textDisabled,
    marginTop: 4,
  },
  saveButton: {
    backgroundColor: Colors.primary,
    margin: Spacing.md,
    padding: Spacing.md,
    borderRadius: BorderRadius.md,
    alignItems: 'center',
  },
  saveButtonText: {
    color: Colors.surface,
    fontSize: 16,
    fontWeight: '600',
  },
});
