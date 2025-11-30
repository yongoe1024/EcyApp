/**
 * 屏幕断点枚举
 */
export enum BreakpointEnum {
  sm = 'sm',
  md = 'md',
  lg = 'lg'
}

/**
 * 屏幕断点工具
 */
export class Breakpoint {
  static of<T>(sm: T, md: T, lg: T, widthBreakpoint: BreakpointEnum): T {
    switch (widthBreakpoint) {
      case BreakpointEnum.sm:
        return sm;
      case BreakpointEnum.md:
        return md;
      case BreakpointEnum.lg:
        return lg;
    }
  }
}

// Text('Test')
//  .fontSize(  BreakpointType.of('14fp', '16fp', '18fp',this.currentWidthBreakpoint) )