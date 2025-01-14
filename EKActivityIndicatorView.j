@implementation EKActivityIndicatorView : CPView
{
    BOOL        _isAnimating;
    BOOL        _shouldUseCSS;
    CPString    _CSSProperty;
    int         _step;
    CPTimer     _timer;
    CPColor     _color;
    float       _colorRed;
    float       _colorGreen;
    float       _colorBlue;
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if(self)
    {
        _isAnimating    = NO;
        _shouldUseCSS   = NO;
    
        [self setColor:[CPColor blackColor]];
        [self setUseCSS:YES];
    }
    return self;
}

- (BOOL)checkCSS
{
    var properties = ["transform", "webkitTransform", "oTransform", "MozTransform", "msTransform"];
    
    for (var i = 0, property; property = properties[i++];)
    {
        if (typeof self._DOMElement.style[property] != "undefined")
        {
            _CSSProperty = property;
            break;
        }
    }
}

- (void)setUseCSS:(BOOL)shouldUseCSS
{   
    // --- Check if we can use CSS3 for rotation
    if (!_CSSProperty)
        [self checkCSS];
    
    _shouldUseCSS = shouldUseCSS;
    
    if (!_isAnimating)
        return;
    
    [self stopAnimating];
    [self startAnimating];
}

- (void)setColor:(CPColor)aColor
{
    _color      = aColor;
    _colorRed   = [aColor redComponent];
    _colorGreen = [aColor greenComponent];
    _colorBlue  = [aColor blueComponent];
    
    if (_shouldUseCSS)
        [self setNeedsDisplay:YES];
}

- (void)setObjectValue:(BOOL)aValue
{
    switch (aValue)
    {
        case YES:
            [self startAnimating];
            break;
        case NO:
            [self stopAnimating];
            break;
    }
}

- (void)startAnimating
{
    if (_isAnimating)
        return;
    
    _isAnimating    = YES;
    _step           = 1;
    
    [self setNeedsDisplay:YES];
    
    _timer          = [CPTimer scheduledTimerWithTimeInterval:0.1
                                                       target:self
                                                     selector:@selector(timerDidFire)
                                                     userInfo:nil
                                                      repeats:YES];
                                                      
}

- (void)stopAnimating
{
    if (!_isAnimating)
        return;
    
    _isAnimating = NO;
    [_timer invalidate];
    [self setNeedsDisplay:YES];
    
    if (_shouldUseCSS && _CSSProperty)
        self._DOMElement.style[_CSSProperty] = "rotate(0deg)";
}

- (BOOL)isAnimating
{
    return _isAnimating;
}

- (CPColor)color
{
    return _color;
}

- (void)timerDidFire
{
    if (_step == 12)
        _step = 1;
    else
        _step++;
    
    // --- Redraw canvas if browser shouldn't / can't rotate
    if (!_CSSProperty || !_shouldUseCSS)
        return [self setNeedsDisplay:YES];
    
    // --- Animate with rotation if the browser is smart enough
    var rad       = _step / 12 * 2 * Math.PI;
    var radString = "rotate(" + rad + "rad)";
    
    self._DOMElement.style[_CSSProperty] = radString;
}

- (void)drawRect:(CGrect)rect
{
    var size    = MIN(rect.size.height, rect.size.width),
        c       = [[CPGraphicsContext currentContext] graphicsPort];

    CGContextClearRect(c, rect);

    if (!_isAnimating)
        return;
    
    var thickness   = size * 0.1,
        length      = size * 0.28,
        radius      = thickness / 2,
        lineRect    = CGRectMake(size / 2 - thickness / 2, 0, thickness, length),
        minx        = CGRectGetMinX(lineRect),
        midx        = CGRectGetMidX(lineRect),
        maxx        = CGRectGetMaxX(lineRect),
        miny        = CGRectGetMinY(lineRect),
        midy        = CGRectGetMidY(lineRect),
        maxy        = CGRectGetMaxY(lineRect),
        delta       = [];
    
    CGContextSetFillColor(c, [CPColor blackColor]);
    
    function fillWithOpacity(opacity)
    {
        CGContextSetFillColor(c, [CPColor colorWithRed:_colorRed green:_colorGreen blue:_colorBlue alpha:opacity]);
    }
    
    for (i=1; i<=12; i++)
    {
        for (j=1; j<=6; j++)
        {
            delta[j] = (_step <= j) ? 12-j : -j;
        }
    
        if (i==_step) CGContextSetFillColor(c, _color);
        else if (i==_step+delta[1]) fillWithOpacity(0.9);
        else if (i==_step+delta[2]) fillWithOpacity(0.8);
        else if (i==_step+delta[3]) fillWithOpacity(0.7);
        else if (i==_step+delta[4]) fillWithOpacity(0.6);
        else if (i==_step+delta[5]) fillWithOpacity(0.5);
        else if (i==_step+delta[6]) fillWithOpacity(0.4);
        else fillWithOpacity(0.3);
    
        CGContextBeginPath(c);
        CGContextMoveToPoint(c, minx, midy);
        CGContextAddArcToPoint(c, minx, miny, midx, miny, radius);
        CGContextAddArcToPoint(c, maxx, miny, maxx, midy, radius);
        CGContextAddArcToPoint(c, maxx, maxy, midx, maxy, radius);
        CGContextAddArcToPoint(c, minx, maxy, minx, midy, radius);
        CGContextClosePath(c);
        CGContextFillPath(c);
        CGContextTranslateCTM(c, size/2, size/2);
        CGContextRotateCTM(c, 30*(Math.PI/180));
        CGContextTranslateCTM(c, -size/2, -size/2);
    }
}

@end

var EKActivityIndicatorViewColor = @"EKActivityIndicatorViewColor";

@implementation EKActivityIndicatorView (CPCoding)

- (id)initWithCoder:(CPCoder)aCoder
{
    self = [super initWithCoder:aCoder];

    if (self)
    {
        [self setColor:[aCoder decodeObjectForKey:EKActivityIndicatorViewColor]];
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:[self color] forKey:EKActivityIndicatorViewColor];
}

@end
