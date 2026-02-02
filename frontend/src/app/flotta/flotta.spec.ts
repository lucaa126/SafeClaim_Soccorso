import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Flotta } from './flotta';

describe('Flotta', () => {
  let component: Flotta;
  let fixture: ComponentFixture<Flotta>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Flotta]
    })
    .compileComponents();

    fixture = TestBed.createComponent(Flotta);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
