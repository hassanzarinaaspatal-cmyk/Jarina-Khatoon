import React from 'react';
import { Text, View, StyleSheet, Linking, Button } from 'react-native';

export default function App() {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Jarina Khatoon</Text>
      <Text style={styles.body}>Welcome! This is a starter Expo app created to run on mobile devices using Expo Go.</Text>
      <Text style={styles.note}>Tap the button to open the project README on GitHub.</Text>
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
  title: {
    fontSize: 28,
    fontWeight: '700',
    marginBottom: 12,
  },
  body: {
    fontSize: 16,
    textAlign: 'center',
    marginBottom: 16,
  },
  note: {
    fontSize: 12,
    color: '#666',
    marginBottom: 8,
  },
});
