import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Richieste } from './richieste';

describe('Richieste', () => {
  let component: Richieste;
  let fixture: ComponentFixture<Richieste>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Richieste]
    })
    .compileComponents();

    fixture = TestBed.createComponent(Richieste);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
