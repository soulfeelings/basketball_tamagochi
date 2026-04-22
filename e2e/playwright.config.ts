import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  timeout: 60000,
  use: {
    headless: true,
    screenshot: 'on',
    video: 'on',
    viewport: { width: 390, height: 844 },
    baseURL: 'http://localhost:8765',
  },
  reporter: [['list'], ['html', { open: 'never', outputFolder: 'report' }]],
  outputDir: './results',
});
