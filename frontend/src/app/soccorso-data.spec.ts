import { TestBed } from '@angular/core/testing';

import { SoccorsoData } from './soccorso-data';

describe('SoccorsoData', () => {
  let service: SoccorsoData;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(SoccorsoData);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
