source('loaddata.R')
source('functions.R')

SAVEPLOTS = TRUE

diagnose = function(ts) {
    par(mfrow=c(2,1))
    acf(ts)
    pacf(ts)
}

sign.test = function(res) {
    n = length(res)
    binom.test(sum(1*(res[2:n]*res[1:(n-1)] < 0)), n-1)
}

save.sign.test = function(res, filename) {
    sink(sprintf('../tables/%s', filename))
    print(sign.test(res))
    sink()
}

qq = function(model) {
    plot.qq.res(residuals(model), model$sigma2)
}

plot.qq.res = function(res, sigma) {
    qqnorm(res)
    lines((-4):4,((-4):4)*sqrt(sigma), type="l", lwd=3, col='red')
}

save.model.summary = function(model, filename) {
    sink(sprintf('../tables/%s', filename))
    print(model)
    sink()
}


plot.and.save('trainingset.pdf', 12, 7,
              plot, train.ts, main='Airline passengers', xlab='Time', 
              ylab='Passengers')
plot.and.save('acf-trainingset.pdf', 7, 7,
              acf, train, main='ACF for the time series')
plot.and.save('pacf-trainingset.pdf', 7, 7,
              pacf, train, main='PACF for the time series')


train.d = diff(train)
plot.and.save('acf-onediff.pdf', 7, 7,
              acf, train.d, lag.max=25, 
              main='ACF for the first order differenced series')
plot.and.save('pacf-onediff.pdf', 7, 7,
              pacf, train.d, lag.max=25,
              main='PACF for the first order differenced series')


train.d2 = diff(train.d, lag=12)
plot.and.save('acf-seasondiff.pdf', 7, 7,
              acf, train.d2, lag.max=25, 
              main='ACF for the first order and seasonal differenced series')
plot.and.save('pacf-seasondiff.pdf', 7, 7,
              pacf, train.d2, lag.max=25,
              main='PACF for the first order and seasonal differenced series')
plot(train.d2, type="l")


m1 = arima(train.ts, order=c(2,1,1), 
           seasonal=list(order=c(0,1,1), period=12), 
           method="ML")
save.model.summary(m1, 'model1.txt')
m1.r = residuals(m1)
m1.r.trim = m1.r[12:78]

plot.and.save('acf-m1.pdf', 7, 7,
              acf, m1.r, lag.max=25,
              main='ACF for the residuals of the seasonal (2,1,1)x(0,1,1)_12 model')
plot.and.save('pacf-m1.pdf', 7, 7,
              pacf, m1.r, lag.max=25,
              main='PACF for the residuals seasonal (2,1,1)x(0,1,1)_12 model')

plot.and.save('residuals-m1.pdf', 7, 7,
              plot, m1.r, type="p", xlim=c(1996,2001.5), ylab='Residuals',
              main='Residuals for the (2,1,1)x(0,1,1)_12 model')

plot.and.save('qq-residuals-m1.pdf', 7, 7, 
              plot.qq.res, m1.r.trim, m1$sigma2)

save.sign.test(m1.r.trim, 'signtest-m1.txt')

hist(m1.r.trim, probability=T, col='blue')
# The Ljung-Box test is a refinement of the Box-Pierce test
# that is described under the heading "Portmanteau lack-of-fit test"
# on page 175 in course text book. See also:
# http://en.wikipedia.org/wiki/Ljung-Box_test 
tsdiag(m1)


sink('../tables/aic-scores.txt')
for (i in 0:5) {
    for (j in 1:3) {
        mi = arima(train.ts, order=c(i,1,j), 
               seasonal=list(order=c(0,1,1), period=12), 
               method="ML")
        print(sprintf('(%d,1,%d): %.02f', i, j, mi$aic))
    }
}
sink()




m2 = arima(train.ts, order=c(0,1,1), seasonal=list(order=c(0,1,1), period=12), 
           include.mean=T, method="ML")
save.model.summary(m2, 'model2.txt')
m2.r = residuals(m2)
m2.r.trim = m2.r[12:78]
m2.p = predict(m2, n.ahead=9)

plot.and.save('acf-m2.pdf', 7, 7,
              acf, m2.r, lag.max=25,
              main='ACF for the residuals of the seasonal (0,1,1)x(0,1,1)_12 model')
plot.and.save('pacf-m2.pdf', 7, 7,
              pacf, m2.r, lag.max=25,
              main='PACF for the residuals seasonal (0,1,1)x(0,1,1)_12 model')

plot.and.save('residuals-m2.pdf', 7, 7,
              plot, m2.r, type="p", xlim=c(1996,2001.5), ylab='Residuals',
              main='Residuals for the (0,1,1)x(0,1,1)_12 model')

plot.and.save('qq-residuals-m2.pdf', 7, 7, 
              plot.qq.res, m2.r.trim, m2$sigma2)

save.sign.test(m2.r.trim, 'signtest-m2.txt')

plot(1:9, m2.p$pred, type="l", ylim=c(35000, 65000))
lines(1:9, test, type="l", col="red")
lines(1:9, m2.p$se+m1.p.se*2, lty=2)
lines(1:9, m2.p$se-m1.p.se*2, lty=2)



plot(dat.ts)

