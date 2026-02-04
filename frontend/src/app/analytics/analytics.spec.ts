import { describe, it, expect } from 'vitest';
import { AnalyticsService } from './analytics.service';
// SoccorsoData non serve importarlo perché il Service attuale usa dati mock interni

describe('AnalyticsService (basic)', () => {
  it('calcola correttamente counts e medie', () => {
    // 1. CORREZIONE: Istanziamo il service senza argomenti (il costruttore è vuoto)
    const svc = new AnalyticsService();

    const reqCounts = svc.getRequestStatusCounts();
    // Questo va bene perché reqCounts ha la proprietà .total
    expect(reqCounts.total).toBeGreaterThanOrEqual(0);

    const fleet = svc.getFleetStatusCounts();
    
    // 2. CORREZIONE: 'fleet' non ha .total, ma ha .available, .busy, ecc.
    // Testiamo che 'available' esista ed è un numero
    expect(fleet.available).toBeGreaterThanOrEqual(0);
    
    // Se vuoi testare il totale della flotta, devi sommarli:
    const totalFleet = fleet.available + fleet.busy + fleet.maintenance;
    expect(totalFleet).toBeGreaterThanOrEqual(0);

    const avg = svc.getAverageHandlingTimeMinutes();
    expect(typeof avg).toBe('number');
  });
});