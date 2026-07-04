import React from 'react';
import { Text, View, StyleSheet, Linking, Button, Image } from 'react-native';

const ICON_URL = 'https://via.placeholder.com/512.png?text=JK';

export default function App() {
  return (
    <View style={styles.container}>
      <Image source={{ uri: ICON_URL }} style={styles.icon} />
      <Text style={styles.title}>Jarina Khatoon</Text>
      <Text style={styles.body}>Welcome! This is a starter Expo app. Tap the button to open the project README on GitHub.</Text>
      <Button title="Open README" onPress={() => Linking.openURL('https://github.com/hassanzarinaaspatal-cmyk/Jarina-Khatoon')} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },
  icon: {
    width: 120,
    height: 120,
    borderRadius: 20,
    marginBottom: 16,
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
    marginBottom: 12,
  },
  body: {
    fontSize: 16,
    textAlign: 'center',
    marginBottom: 16,
  }
});
