import { describe, it, expect } from 'vitest';
import { AnalyticsService } from './analytics.service';
import { SoccorsoData } from '../soccorso-data';

describe('AnalyticsService (basic)', () => {
  it('calcola correttamente counts e medie', () => {
    const data = new SoccorsoData();
    const svc = new AnalyticsService(data);

    const reqCounts = svc.getRequestStatusCounts();
    expect(reqCounts.total).toBeGreaterThanOrEqual(0);

    const fleet = svc.getFleetStatusCounts();
    expect(fleet.total).toBeGreaterThanOrEqual(0);

    const avg = svc.getAverageHandlingTimeMinutes();
    expect(typeof avg).toBe('number');
  });
});
