import { ComponentFixture, TestBed } from '@angular/core/testing';

import { SoccorsoDash } from './soccorso-dash';

describe('SoccorsoDash', () => {
  let component: SoccorsoDash;
  let fixture: ComponentFixture<SoccorsoDash>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [SoccorsoDash]
    })
    .compileComponents();

    fixture = TestBed.createComponent(SoccorsoDash);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
